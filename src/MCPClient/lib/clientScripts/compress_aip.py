#!/usr/bin/env python

import argparse
import os.path
import sys

import django
from django.db import transaction

django.setup()
# dashboard
from main.models import SIP

# archivematicaCommon
import databaseFunctions
from executeOrRunSubProcess import executeOrRun


def update_unit(sip_uuid, compressed_location):
    # Set aipFilename in Unit
    SIP.objects.filter(uuid=sip_uuid).update(
        aip_filename=os.path.basename(compressed_location)
    )


def compress_aip(
    job, compression, compression_level, sip_directory, sip_name, sip_uuid
):
    """Compresses AIP according to compression algorithm and level.
    compression = AIP compression algorithm, format: <program>-<algorithm>, eg. 7z-lzma, pbzip2-
    compression_level = AIP compression level, integer between 1 and 9 inclusive
    sip_directory = Absolute path to the directory where the SIP is
    sip_name = User-provided name of the SIP
    sip_uuid = SIP UUID

    Example inputs:
    compressAIP.py
        7z-lzma
        5
        /var/archivematica/sharedDirectory/watchedDirectories/workFlowDecisions/compressionAIPDecisions/ep-d87d5845-bd07-4200-b1a4-928e0cb6e1e4/
        ep
        d87d5845-bd07-4200-b1a4-928e0cb6e1e4
    """
    try:
        program, compression_algorithm = compression.split("-")
    except ValueError:
        msg = "Invalid program-compression algorithm: {}".format(compression)
        job.pyprint(msg, file=sys.stderr)
        return 255

    archive_path = "{name}-{uuid}".format(name=sip_name, uuid=sip_uuid)
    uncompressed_location = sip_directory + archive_path

    # Even though no actual compression is taking place,
    # the location still needs to be set in the unit to ensure that the
    # %AIPFilename% variable is set appropriately.
    # Setting it to an empty string ensures the common
    # "%SIPDirectory%%AIPFilename%" pattern still points at the right thing.
    if program == "None":
        update_unit(sip_uuid, uncompressed_location)
        return 0

    job.pyprint(
        "Compressing {} with {}, algorithm {}, level {}".format(
            uncompressed_location, program, compression_algorithm, compression_level
        )
    )

    if program == "7z":
        compressed_location = uncompressed_location + ".7z"
        command = '/usr/bin/7z a -bd -t7z -y -m0={algorithm} -mx={level} -mta=on -mtc=on -mtm=on -mmt=on "{compressed_location}" "{uncompressed_location}"'.format(
            algorithm=compression_algorithm,
            level=compression_level,
            uncompressed_location=uncompressed_location,
            compressed_location=compressed_location,
        )
        tool_info_command = (
            'echo program="7z"\; '
            'algorithm="{}"\; '
            'version="`7z | grep Version`"'.format(compression_algorithm)
        )
    elif program == "pbzip2":
        compressed_location = uncompressed_location + ".tar.bz2"
        command = '/bin/tar -c --directory "{sip_directory}" "{archive_path}" | /usr/bin/pbzip2 --compress -{level} > "{compressed_location}"'.format(
            sip_directory=sip_directory,
            archive_path=archive_path,
            level=compression_level,
            compressed_location=compressed_location,
        )
        tool_info_command = (
            'echo program="pbzip2"\; '
            'algorithm="{}"\; '
            'version="$((pbzip2 -V) 2>&1)"'.format(compression_algorithm)
        )
    elif program == "gzip":
        compressed_location = uncompressed_location + ".tar.gz"
        command = '/bin/tar -c --directory "{sip_directory}" "{archive_path}" | /bin/gzip -{level} > "{compressed_location}"'.format(
            sip_directory=sip_directory,
            archive_path=archive_path,
            level=compression_level,
            compressed_location=compressed_location,
        )
        tool_info_command = (
            'echo program="gzip"\; '
            'algorithm="{}"\; '
            'version="$((gzip -V) 2>&1)"'.format(compression_algorithm)
        )
    else:
        msg = "Program {} not recognized, exiting script prematurely.".format(program)
        job.pyprint(msg, file=sys.stderr)
        return 255

    job.pyprint("Executing command:", command)
    exit_code, std_out, std_err = executeOrRun(
        "bashScript", command, printing=True, capture_output=True
    )
    job.write_output(std_out)
    job.write_error(std_err)

    # Add new AIP File
    file_uuid = sip_uuid
    databaseFunctions.insertIntoFiles(
        fileUUID=file_uuid,
        filePath=compressed_location.replace(sip_directory, "%SIPDirectory%", 1),
        sipUUID=sip_uuid,
        use="aip",
    )

    # Add compression event
    job.pyprint("Tool info command:", tool_info_command)
    _, tool_info, tool_info_err = executeOrRun(
        "bashScript", tool_info_command, printing=True, capture_output=True
    )
    job.write_output(tool_info)
    job.write_error(tool_info_err)
    tool_output = 'Standard Output="{}"; Standard Error="{}"'.format(std_out, std_err)
    databaseFunctions.insertIntoEvents(
        eventType="compression",
        eventDetail=tool_info,
        eventOutcomeDetailNote=tool_output,
        fileUUID=file_uuid,
    )

    update_unit(sip_uuid, compressed_location)

    return exit_code


def call(jobs):
    parser = argparse.ArgumentParser(description="Compress an AIP.")
    parser.add_argument("compression", type=str, help="%AIPCompressionAlgorithm%")
    parser.add_argument("compression_level", type=str, help="%AIPCompressionLevel%")
    parser.add_argument("sip_directory", type=str, help="%SIPDirectory%")
    parser.add_argument("sip_name", type=str, help="%SIPName%")
    parser.add_argument("sip_uuid", type=str, help="%SIPUUID%")

    with transaction.atomic():
        for job in jobs:
            with job.JobContext():
                args = parser.parse_args(job.args[1:])
                job.set_status(
                    compress_aip(
                        job,
                        args.compression,
                        args.compression_level,
                        args.sip_directory,
                        args.sip_name,
                        args.sip_uuid,
                    )
                )
