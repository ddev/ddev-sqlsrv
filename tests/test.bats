setup() {
  set -eu -o pipefail
  export DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )/.."
  export TESTDIR=~/tmp/test-addon-sqlsrv
  mkdir -p $TESTDIR
  export PROJNAME=test-addon-sqlsrv
  export DDEV_NON_INTERACTIVE=true
  export MSSQL_HOST=localhost
  export MSSQL_EXTERNAL_PORT=1433
  export MSSQL_SA_PASSWORD=Password12!
  export MSSQL_PID=Developer
  ddev delete -Oy ${PROJNAME} >/dev/null 2>&1 || true
  cd "${TESTDIR}"
  ddev config --project-name=${PROJNAME}
  ddev start -y >/dev/null
}

teardown() {
  set -eu -o pipefail
  cd ${TESTDIR} || ( printf "unable to cd to ${TESTDIR}\n" && exit 1 )
  ddev delete -Oy ${PROJNAME} >/dev/null 2>&1
  [ "${TESTDIR}" != "" ] && rm -rf ${TESTDIR}
}

@test "install from directory" {
  set -eu -o pipefail
  cd ${TESTDIR}
  echo "# ddev get ${DIR} with project ${PROJNAME} in ${TESTDIR} ($(pwd))" >&3
  ddev get ${DIR}
  ddev restart
  # Checks that the sqlsrv drivers for PHP are installed.
  ddev exec "php -i" | grep "sqlsrv"
  # Checks sqlsrv connection.
  ddev -s sqlsrv exec "/opt/mssql-tools/bin/sqlcmd -P ${MSSQL_SA_PASSWORD} -S ${MSSQL_HOST} -U SA -Q 'SELECT name, database_id, create_date FROM sys.databases;'" | grep master
}

@test "install from release" {
  set -eu -o pipefail
  cd ${TESTDIR} || ( printf "unable to cd to ${TESTDIR}\n" && exit 1 )
  echo "# ddev get ddev/ddev-sqlsrv with project ${PROJNAME} in ${TESTDIR} ($(pwd))" >&3
  ddev get ddev/ddev-sqlsrv
  ddev restart >/dev/null
  # Checks that the sqlsrv drivers for PHP are installed.
  ddev exec "php -i" | grep "sqlsrv"
  # Checks sqlsrv connection.
  ddev -s sqlsrv exec "/opt/mssql-tools/bin/sqlcmd -P ${MSSQL_SA_PASSWORD} -S ${MSSQL_HOST} -U SA -Q 'SELECT name, database_id, create_date FROM sys.databases;'" | grep master
}
