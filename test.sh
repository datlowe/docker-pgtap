#!/bin/bash
DATABASE=
HOST=
PORT=5432
USER="postgres"
PASSWORD=
TESTS="/t/*.sql"

function usage() { printf "Usage: $0 -h host -d database -p port -u username -w password -t tests\n" 1>&2; exit 1; }

while getopts d:h:p:u:w:b:n:t: OPTION
do
  case $OPTION in
    d)
      DATABASE=$OPTARG
      ;;
    h)
      HOST=$OPTARG
      ;;
    p)
      PORT=$OPTARG
      ;;
    u)
      USER=$OPTARG
      ;;
    w)
      PASSWORD=$OPTARG
      ;;
    t)
      TESTS=$OPTARG
      ;;
    *)
      usage
      ;;
  esac
done

if [[ -z $DATABASE ]] || [[ -z $HOST ]] || [[ -z $PORT ]] || [[ -z $USER ]] || [[ -z $TESTS ]]
then
  usage
  exit 1
fi

printf "Running tests: $TESTS\n" 1>&2
# install pgtap
PGPASSWORD=$PASSWORD psql -h $HOST -p $PORT -d $DATABASE -U $USER -f /pgtap/sql/pgtap.sql > /dev/null 2>&1

rc=$?
# exit if pgtap failed to install
if [[ $rc != 0 ]] ; then
  printf "pgTap was not installed properly. Unable to run tests!\n" 1>&2
  exit $rc
fi
# run the tests
PGPASSWORD=$PASSWORD pg_prove -h $HOST -p $PORT -d $DATABASE -U $USER $TESTS
rc=$?
# uninstall pgtap
PGPASSWORD=$PASSWORD psql -h $HOST -p $PORT -d $DATABASE -U $USER -f /pgtap/sql/uninstall_pgtap.sql > /dev/null 2>&1
# exit with return code of the tests
exit $rc
