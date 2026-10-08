#!/usr/bin/env bats

# Bats is a testing framework for Bash
# Documentation https://bats-core.readthedocs.io/en/stable/
# Bats libraries documentation https://github.com/ztombol/bats-docs

# For local tests, install bats-core, bats-assert, bats-file, bats-support
# And run this in the add-on root directory:
#   bats ./tests/test.bats
# To exclude release tests:
#   bats ./tests/test.bats --filter-tags '!release'
# For debugging:
#   bats ./tests/test.bats --show-output-of-passing-tests --verbose-run --print-output-on-failure

setup() {
  set -eu -o pipefail

  # Override this variable for your add-on:
  export GITHUB_REPO=ddev/ddev-sqlsrv

  TEST_BREW_PREFIX="$(brew --prefix 2>/dev/null || true)"
  export BATS_LIB_PATH="${BATS_LIB_PATH}:${TEST_BREW_PREFIX}/lib:/usr/lib/bats"
  bats_load_library bats-assert
  bats_load_library bats-file
  bats_load_library bats-support

  export DIR="$(cd "$(dirname "${BATS_TEST_FILENAME}")/.." >/dev/null 2>&1 && pwd)"
  export PROJNAME="test-$(basename "${GITHUB_REPO}")"
  mkdir -p ~/tmp
  export TESTDIR=$(mktemp -d ~/tmp/${PROJNAME}.XXXXXX)
  export DDEV_NONINTERACTIVE=true
  export DDEV_NO_INSTRUMENTATION=true
  ddev delete -Oy "${PROJNAME}" >/dev/null 2>&1 || true
  cd "${TESTDIR}"
  run ddev config --project-name="${PROJNAME}" --project-tld=ddev.site
  assert_success
  run ddev start -y
  assert_success
}

health_checks() {
  run ddev php -m
  assert_success
  assert_line "sqlsrv"
  assert_line "pdo_sqlsrv"

  # Both extensions must be able to connect, which needs a compatible ODBC driver
  run ddev php -r '$c = new PDO("sqlsrv:Server=sqlsrv;TrustServerCertificate=1", getenv("SQLCMDUSER"), getenv("SQLCMDPASSWORD")); echo $c->query("SELECT 42")->fetchColumn();'
  assert_success
  assert_output "42"

  run ddev php -r '$c = sqlsrv_connect("sqlsrv", ["UID" => getenv("SQLCMDUSER"), "PWD" => getenv("SQLCMDPASSWORD"), "TrustServerCertificate" => 1]); echo $c ? "connected" : print_r(sqlsrv_errors(), true);'
  assert_success
  assert_output "connected"

  run ddev sqlcmd -Q "SELECT name, database_id, create_date FROM sys.databases;"
  assert_success
  assert_output --partial "master"

  run ddev exec sqlcmd -C -Q "SELECT name, database_id, create_date FROM sys.databases;"
  assert_success
  assert_output --partial "master"
}

# Installs the add-on from the directory for the given PHP version and runs health checks.
install_from_directory() {
  local php_version="$1"

  run ddev config --php-version="${php_version}"
  assert_success

  run ddev dotenv set .ddev/.env.sqlsrv --mssql-sa-password='Password12345!'
  assert_success
  assert_file_exist .ddev/.env.sqlsrv

  echo "# ddev add-on get ${DIR} with PHP ${php_version} in $(pwd)" >&3
  run ddev add-on get "${DIR}"
  assert_success
  run ddev restart -y
  assert_success
  health_checks
}

teardown() {
  set -eu -o pipefail
  ddev delete -Oy "${PROJNAME}" >/dev/null 2>&1
  # Persist TESTDIR if running inside GitHub Actions. Useful for uploading test result artifacts
  # See example at https://github.com/ddev/github-action-add-on-test#preserving-artifacts
  if [ -n "${GITHUB_ENV:-}" ]; then
    [ -e "${GITHUB_ENV:-}" ] && echo "TESTDIR=${HOME}/tmp/${PROJNAME}" >> "${GITHUB_ENV}"
  else
    [ "${TESTDIR}" != "" ] && rm -rf "${TESTDIR}"
  fi
}

# bats test_tags=php70-php73
@test "install from directory PHP 7.0" {
  set -eu -o pipefail
  install_from_directory 7.0
}

# bats test_tags=php70-php73
@test "install from directory PHP 7.1" {
  set -eu -o pipefail
  install_from_directory 7.1
}

# bats test_tags=php70-php73
@test "install from directory PHP 7.2" {
  set -eu -o pipefail
  install_from_directory 7.2
}

# bats test_tags=php70-php73
@test "install from directory PHP 7.3" {
  set -eu -o pipefail
  install_from_directory 7.3
}

# bats test_tags=php74-php82
@test "install from directory PHP 7.4" {
  set -eu -o pipefail
  install_from_directory 7.4
}

# bats test_tags=php74-php82
@test "install from directory PHP 8.0" {
  set -eu -o pipefail
  install_from_directory 8.0
}

# bats test_tags=php74-php82
@test "install from directory PHP 8.1" {
  set -eu -o pipefail
  install_from_directory 8.1
}

# bats test_tags=php74-php82
@test "install from directory PHP 8.2" {
  set -eu -o pipefail
  install_from_directory 8.2
}

# bats test_tags=php83-php85
@test "install from directory PHP 8.3" {
  set -eu -o pipefail
  install_from_directory 8.3
}

# bats test_tags=php83-php85
@test "install from directory PHP 8.4" {
  set -eu -o pipefail
  install_from_directory 8.4
}

# bats test_tags=php83-php85
@test "install from directory PHP 8.5" {
  set -eu -o pipefail
  install_from_directory 8.5
}

# bats test_tags=release
@test "install from release" {
  set -eu -o pipefail
  echo "# ddev add-on get ${GITHUB_REPO} with project ${PROJNAME} in $(pwd)" >&3
  run ddev add-on get "${GITHUB_REPO}"
  assert_success
  run ddev restart -y
  assert_success
  health_checks
}
