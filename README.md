[![tests](https://github.com/ddev/ddev-sqlsrv/actions/workflows/tests.yml/badge.svg)](https://github.com/ddev/ddev-sqlsrv/actions/workflows/tests.yml) ![project is maintained](https://img.shields.io/maintenance/yes/2024.svg)

# ddev-sqlsrv <!-- omit in toc -->

* [What is ddev-sqlsrv?](#what-is-ddev-sqlsrv)
* [Components of the repository](#components-of-the-repository)
* [Getting started](#getting-started)

## What is ddev-sqlsrv?

This add-on quickly installs the MS SQL server into a DDEV project.
It is based on the [mcr.microsoft.com/mssql/server](https://hub.docker.com/_/microsoft-mssql-server) image.

You have to keep in mind that the [mssql-docker](https://github.com/microsoft/mssql-docker) does not natively work on M1 (arm64).
Some workarounds are described in the following threads:
* [Does not work on Mac M1](https://github.com/microsoft/mssql-docker/issues/734)
* [MSSQL container for aarch64 (arm64) for better performance](https://github.com/microsoft/mssql-docker/issues/802)

## Installation

**Due to lack of upstream support, this add-on can only be used with amd64 machines, and is not usable on arm64 machines like Apple Silicon computers.**

For DDEV v1.23.5 or above run

```bash
ddev add-on get ddev/ddev-sqlsrv
```

For earlier versions of DDEV run

```bash
ddev get ddev/ddev-sqlsrv
```

Then restart your project

```bash
ddev restart
```

If your project already has a `.ddev/.env` file, you need to add the following lines to it:

```dotenv
MSSQL_EXTERNAL_PORT=1433
MSSQL_SA_PASSWORD=Password12!
MSSQL_PID=Evaluation
MSSQL_DB_NAME=master
MSSQL_HOST=sqlsrv
```

## Drupal Notice

Drupal CMS needs the database function installed that is mimicking the Regex function as Drupal requires. As a one-time setup for Drupal, install the database function by running the following command from your project's directory:

```bash
ddev drupal-regex
```

This script also changes the setting for the following database variables:

* `show advanced options` will be set to 1
* `clr strict security` will be set to 0
* `clr enable` will be set to 1

Drupal also required the [`sqlsrv` module](https://www.drupal.org/project/sqlsrv) to be installed as it is provides the database driver for SQL Server. The module can be installed with composer with the following command:

```bash
ddev composer require drupal/sqlsrv
```

**There is an open issue for Drupal 9.4+ installations. Until merged, you need to apply [patch #4](https://www.drupal.org/project/sqlsrv/issues/3291199#comment-14576456), see [Call to a member function fetchField() on null
](https://www.drupal.org/project/sqlsrv/issues/3291199)**

## Manually enabling MySQL/MariaDB

**This addons disables the default database by automatically adding `omit_containers: [db,dba]` in the `config.sqlsrv.yaml`**

If your project needs to use both MariaDB and MS SQL Server databases, you have to remove `#ddev-generated` and
`omit_containers: [db,dba]` from `config.sqlsrv.yaml`.

See [.ddev/config.yaml Options](https://ddev.readthedocs.io/en/stable/users/extend/config_yaml/) for additional notes.

## Links with useful information

* [SQL Server docker hub](https://hub.docker.com/_/microsoft-mssql-server)
* [Installing the ODBC driver for SQL Server](https://docs.microsoft.com/en-us/sql/connect/odbc/linux-mac/installing-the-microsoft-odbc-driver-for-sql-server)
* [Installing the ODBC driver for SQL Server Tutorial](https://docs.microsoft.com/en-us/sql/connect/php/installation-tutorial-linux-mac)
* [Installation tutorial for MS drivers for PHP](https://docs.microsoft.com/en-us/sql/connect/php/installation-tutorial-linux-mac)
* [The SQLCMD utility](https://docs.microsoft.com/en-us/sql/tools/sqlcmd-utility)
* [The SQL Server on Linux](https://docs.microsoft.com/en-us/sql/linux/sql-server-linux-overview)
* [The password policy](https://docs.microsoft.com/en-us/sql/relational-databases/security/password-policy)
* [The SQL Server environment variables](https://docs.microsoft.com/en-us/sql/linux/sql-server-linux-configure-environment-variables)
* [Beakerboy's Drupal Regex database function](https://github.com/Beakerboy/drupal-sqlsrv-regex)
* [Drupal's module for the SQL Server](https://www.drupal.org/project/sqlsrv)
* [Github MS drivers for PHP](https://github.com/microsoft/msphpsql)

Note that more advanced techniques are discussed in [DDEV docs](https://ddev.readthedocs.io/en/latest/users/extend/additional-services/#additional-service-configurations-and-add-ons-for-ddev).

**Contributed and maintained by [@robertoperuzzo](https://github.com/robertoperuzzo) based on the original [ddev-contrib recipe](https://github.com/ddev/ddev-contrib/tree/master/docker-compose-services/sqlsrv) by [drupal-daffie](https://github.com/drupal-daffie)**
