su archivematica -c ' \
    python manage.py migrate --noinput
    python manage.py install \
        --username="test" \
        --password="test" \
        --email="test@test.com" \
        --org-name="test" \
        --org-id="test" \
        --api-key="test" \
        --ss-url="${ARCHIVEMATICA_SS_URL}" \
	--ss-user="test" \
	--ss-api-key="test" \
        --site-url="${ARCHIVEMATICA_SITE_URL}"
';

bash -c ' \
    cd /src/dashboard/frontend
    npm install --unsafe-perm
    sleep 3600
';
