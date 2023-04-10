[![tests](https://github.com/robertoperuzzo/ddev-sqlsrv/actions/workflows/tests.yml/badge.svg)](https://github.com/robertoperuzzo/ddev-sqlsrv/actions/workflows/tests.yml) ![project is maintained](https://img.shields.io/maintenance/yes/2024.svg)

# ddev-sqlsrv <!-- omit in toc -->

* [What is ddev-sqlsrv?](#what-is-ddev-sqlsrv)
* [Components of the repository](#components-of-the-repository)
* [Getting started](#getting-started)

## What is ddev-sqlsrv?

This add-on quickly installs the MS SQL server into a DDEV project.
It is based on the [mcr.microsoft.com/mssql/server](https://hub.docker.com/_/microsoft-mssql-server) image.

## Installation

**Due to lack of upstream support, this add-on can only be used with amd64 machines, and is not usable on arm64 machines like Apple Silicon computers.**

```bash
ddev get robertoperuzzo/ddev-sqlsrv
ddev restart
```

If in your project you already have a `.ddev/.env` file, you need to add the following lines to it:

```dotenv
MSSQL_EXTERNAL_PORT=1433
MSSQL_SA_PASSWORD=Password12!
MSSQL_PID=Evaluation
MSSQL_DB_NAME=master
MSSQL_HOST=localhost
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

Drupal also the module `sqlsrv` to be installed as it is providing the database driver for SQL Server. The module can be installed with composer with the following command:

```bash
ddev composer require drupal/sqlsrv
```

**For Drupal 9.4+ you need the patch #4 posted in the issue [Call to a member function fetchField() on null
](https://www.drupal.org/project/sqlsrv/issues/3291199)**

## Disabling MySQL & MariaSQL

* If your project only uses a SQL Server database, you can disable the MySql & MariaDb services.
* Run the following command from your project root.

```bash
ddev config --omit-containers db
```

* Alternatively, you can update your project's `.ddev/config.yaml` directly by updating the following line:

```yaml
omit_containers: [db]
```

* See [.ddev/config.yaml Options](https://ddev.readthedocs.io/en/stable/users/extend/config_yaml/) for additional notes.

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
