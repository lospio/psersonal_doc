- env
	```bash
	export PATRONI_LOG_LOGGERS="{patroni.postmaster: WARNING, urllib3: DEBUG}"
	export PATRONI_LOG_DIR=/var/lib/pgsql/10/patroni_log
	export PATRONI_LOG_LEVEL=DEBUG
	
	```