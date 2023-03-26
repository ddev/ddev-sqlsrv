setup() {
  set -eu -o pipefail
  export DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )/.."
  export TESTDIR=~/tmp/test-addon-sqlsrv
  mkdir -p $TESTDIR
  export PROJNAME=test-addon-sqlsrv
  export DDEV_NON_INTERACTIVE=true
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
  # Do something here to verify functioning extra service
  # For extra credit, use a real CMS with actual config.
  # ddev exec "curl -s elasticsearch:9200" | grep "${PROJNAME}-elasticsearch"
}

@test "install from release" {
  set -eu -o pipefail
  cd ${TESTDIR} || ( printf "unable to cd to ${TESTDIR}\n" && exit 1 )
  echo "# ddev get ddev/ddev-sqlsrv with project ${PROJNAME} in ${TESTDIR} ($(pwd))" >&3
  ddev get ddev/ddev-sqlsrv
  ddev restart >/dev/null
  # Do something useful here that verifies the add-on
  # ddev exec "curl -s elasticsearch:9200" | grep "${PROJNAME}-elasticsearch"
}
