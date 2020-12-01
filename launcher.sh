CONF=$1; shift

echo "[ application ]" > $CONF
[ ! -z "${CLAMMIT_LISTEN}" ] && echo "listen=$CLAMMIT_LISTEN" >> $CONF
[ ! -z "${CLAMMIT_APP_URL}" ] && echo "application-url=$CLAMMIT_APP_URL" >> $CONF
[ ! -z "${CLAMMIT_CLAMD_URL}" ] && echo "clamd-url=$CLAMMIT_CLAMD_URL" >> $CONF
[ ! -z "${CLAMMIT_LOG_FILE}" ] && echo "log-file=$CLAMMIT_LOG_FILE" >> $CONF
[ ! -z "${CLAMMIT_TEST_PAGES}" ] && echo "test-pages=$CLAMMIT_TEST_PAGES" >> $CONF
[ ! -z "${CLAMMIT_DEBUG}" ] && echo "debug=$CLAMMIT_DEBUG" >> $CONF
[ ! -z "${CLAMMIT_STATUS_CODE}" ] && echo "virus-status-code=$CLAMMIT_STATUS_CODE" >> $CONF
[ ! -z "${CLAMMIT_MEMORY_THRESHOLD}" ] && echo "content-memory-threshold=$CLAMMIT_MEMORY_THRESHOLD" >> $CONF
[ ! -z "${CLAMMIT_THREADS}" ] && echo "num-threads=$CLAMMIT_THREADS" >> $CONF
echo "running clammit with config $CONF"
cat $CONF
$@