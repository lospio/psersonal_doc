[Documentation](https://www.postgresql.org/docs/ "Documentation") → [PostgreSQL 10](https://www.postgresql.org/docs/10/index.html)

Supported Versions: [Current](https://www.postgresql.org/docs/current/app-psql.html "PostgreSQL 14 - psql") ([14](https://www.postgresql.org/docs/14/app-psql.html "PostgreSQL 14 - psql")) / [13](https://www.postgresql.org/docs/13/app-psql.html "PostgreSQL 13 - psql") / [12](https://www.postgresql.org/docs/12/app-psql.html "PostgreSQL 12 - psql") / [11](https://www.postgresql.org/docs/11/app-psql.html "PostgreSQL 11 - psql") / [10](https://www.postgresql.org/docs/10/app-psql.html "PostgreSQL 10 - psql")

Development Versions: [devel](https://www.postgresql.org/docs/devel/app-psql.html "PostgreSQL devel - psql")

Unsupported versions: [9.6](https://www.postgresql.org/docs/9.6/app-psql.html "PostgreSQL 9.6 - psql") / [9.5](https://www.postgresql.org/docs/9.5/app-psql.html "PostgreSQL 9.5 - psql") / [9.4](https://www.postgresql.org/docs/9.4/app-psql.html "PostgreSQL 9.4 - psql") / [9.3](https://www.postgresql.org/docs/9.3/app-psql.html "PostgreSQL 9.3 - psql") / [9.2](https://www.postgresql.org/docs/9.2/app-psql.html "PostgreSQL 9.2 - psql") / [9.1](https://www.postgresql.org/docs/9.1/app-psql.html "PostgreSQL 9.1 - psql") / [9.0](https://www.postgresql.org/docs/9.0/app-psql.html "PostgreSQL 9.0 - psql") / [8.4](https://www.postgresql.org/docs/8.4/app-psql.html "PostgreSQL 8.4 - psql") / [8.3](https://www.postgresql.org/docs/8.3/app-psql.html "PostgreSQL 8.3 - psql") / [8.2](https://www.postgresql.org/docs/8.2/app-psql.html "PostgreSQL 8.2 - psql") / [8.1](https://www.postgresql.org/docs/8.1/app-psql.html "PostgreSQL 8.1 - psql") / [8.0](https://www.postgresql.org/docs/8.0/app-psql.html "PostgreSQL 8.0 - psql") / [7.4](https://www.postgresql.org/docs/7.4/app-psql.html "PostgreSQL 7.4 - psql") / [7.3](https://www.postgresql.org/docs/7.3/app-psql.html "PostgreSQL 7.3 - psql") / [7.2](https://www.postgresql.org/docs/7.2/app-psql.html "PostgreSQL 7.2 - psql") / [7.1](https://www.postgresql.org/docs/7.1/app-psql.html "PostgreSQL 7.1 - psql")

| psql |
| :-: |
| [Prev](https://www.postgresql.org/docs/10/app-psql.htmlapp-pgrestore.html "pg_restore")  | [Up](https://www.postgresql.org/docs/10/app-psql.htmlreference-client.html "PostgreSQL Client Applications") | PostgreSQL Client Applications | [Home](https://www.postgresql.org/docs/10/app-psql.htmlindex.html "PostgreSQL 10.20 Documentation") |  [Next](https://www.postgresql.org/docs/10/app-psql.htmlapp-reindexdb.html "reindexdb") |

___

## psql

psql — PostgreSQL interactive terminal

## Synopsis

`psql` \[_`option`_...\] \[_`dbname`_ \[_`username`_\]\]

## Description

psql is a terminal-based front-end to PostgreSQL. It enables you to type in queries interactively, issue them to PostgreSQL, and see the query results. Alternatively, input can be from a file or from command line arguments. In addition, psql provides a number of meta-commands and various shell-like features to facilitate writing scripts and automating a wide variety of tasks.

## Options

`-a`  
`--echo-all`

Print all nonempty input lines to standard output as they are read. (This does not apply to lines read interactively.) This is equivalent to setting the variable `ECHO` to `all`.

`-A`  
`--no-align`

Switches to unaligned output mode. (The default output mode is otherwise aligned.) This is equivalent to `\pset format unaligned`.

`-b`  
`--echo-errors`

Print failed SQL commands to standard error output. This is equivalent to setting the variable `ECHO` to `errors`.

``-c _`command`_``  
``--command=_`command`_``

Specifies that psql is to execute the given command string, _`command`_. This option can be repeated and combined in any order with the `-f` option. When either `-c` or `-f` is specified, psql does not read commands from standard input; instead it terminates after processing all the `-c` and `-f` options in sequence.

_`command`_ must be either a command string that is completely parsable by the server (i.e., it contains no psql\-specific features), or a single backslash command. Thus you cannot mix SQL and psql meta-commands within a `-c` option. To achieve that, you could use repeated `-c` options or pipe the string into psql, for example:

```
psql -c '\x' -c 'SELECT * FROM foo;'
```

or

```
echo '\x \\ SELECT * FROM foo;' | psql
```

(`\\` is the separator meta-command.)

Each SQL command string passed to `-c` is sent to the server as a single query. Because of this, the server executes it as a single transaction even if the string contains multiple SQL commands, unless there are explicit `BEGIN`/`COMMIT` commands included in the string to divide it into multiple transactions. Also, psql only prints the result of the last SQL command in the string. This is different from the behavior when the same string is read from a file or fed to psql's standard input, because then psql sends each SQL command separately.

Because of this behavior, putting more than one command in a single `-c` string often has unexpected results. It's better to use repeated `-c` commands or feed multiple commands to psql's standard input, either using echo as illustrated above, or via a shell here-document, for example:

```
psql <<EOF
\x
SELECT * FROM foo;
EOF
```

``-d _`dbname`_``  
``--dbname=_`dbname`_``

Specifies the name of the database to connect to. This is equivalent to specifying _`dbname`_ as the first non-option argument on the command line. The _`dbname`_ can be a [connection string](https://www.postgresql.org/docs/10/app-psql.htmllibpq-connect.html#LIBPQ-CONNSTRING "33.1.1. Connection Strings"). If so, connection string parameters will override any conflicting command line options.

`-e`  
`--echo-queries`

Copy all SQL commands sent to the server to standard output as well. This is equivalent to setting the variable `ECHO` to `queries`.

`-E`  
`--echo-hidden`

Echo the actual queries generated by `\d` and other backslash commands. You can use this to study psql's internal operations. This is equivalent to setting the variable `ECHO_HIDDEN` to `on`.

``-f _`filename`_``  
``--file=_`filename`_``

Read commands from the file _`filename`_, rather than standard input. This option can be repeated and combined in any order with the `-c` option. When either `-c` or `-f` is specified, psql does not read commands from standard input; instead it terminates after processing all the `-c` and `-f` options in sequence. Except for that, this option is largely equivalent to the meta-command `\i`.

If _`filename`_ is `-` (hyphen), then standard input is read until an EOF indication or `\q` meta-command. This can be used to intersperse interactive input with input from files. Note however that Readline is not used in this case (much as if `-n` had been specified).

Using this option is subtly different from writing ``psql < _`filename`_``. In general, both will do what you expect, but using `-f` enables some nice features such as error messages with line numbers. There is also a slight chance that using this option will reduce the start-up overhead. On the other hand, the variant using the shell's input redirection is (in theory) guaranteed to yield exactly the same output you would have received had you entered everything by hand.

``-F _`separator`_``  
``--field-separator=_`separator`_``

Use _`separator`_ as the field separator for unaligned output. This is equivalent to `\pset fieldsep` or `\f`.

``-h _`hostname`_``  
``--host=_`hostname`_``

Specifies the host name of the machine on which the server is running. If the value begins with a slash, it is used as the directory for the Unix-domain socket.

`-H`  
`--html`

Turn on HTML tabular output. This is equivalent to `\pset format html` or the `\H` command.

`-l`  
`--list`

List all available databases, then exit. Other non-connection options are ignored. This is similar to the meta-command `\list`.

When this option is used, psql will connect to the database `postgres`, unless a different database is named on the command line (option `-d` or non-option argument, possibly via a service entry, but not via an environment variable).

``-L _`filename`_``  
``--log-file=_`filename`_``

Write all query output into file _`filename`_, in addition to the normal output destination.

`-n`  
`--no-readline`

Do not use Readline for line editing and do not use the command history. This can be useful to turn off tab expansion when cutting and pasting.

``-o _`filename`_``  
``--output=_`filename`_``

Put all query output into file _`filename`_. This is equivalent to the command `\o`.

``-p _`port`_``  
``--port=_`port`_``

Specifies the TCP port or the local Unix-domain socket file extension on which the server is listening for connections. Defaults to the value of the `PGPORT` environment variable or, if not set, to the port specified at compile time, usually 5432.

``-P _`assignment`_``  
``--pset=_`assignment`_``

Specifies printing options, in the style of `\pset`. Note that here you have to separate name and value with an equal sign instead of a space. For example, to set the output format to LaTeX, you could write `-P format=latex`.

`-q`  
`--quiet`

Specifies that psql should do its work quietly. By default, it prints welcome messages and various informational output. If this option is used, none of this happens. This is useful with the `-c` option. This is equivalent to setting the variable `QUIET` to `on`.

``-R _`separator`_``  
``--record-separator=_`separator`_``

Use _`separator`_ as the record separator for unaligned output. This is equivalent to `\pset recordsep`.

`-s`  
`--single-step`

Run in single-step mode. That means the user is prompted before each command is sent to the server, with the option to cancel execution as well. Use this to debug scripts.

`-S`  
`--single-line`

Runs in single-line mode where a newline terminates an SQL command, as a semicolon does.

### Note

This mode is provided for those who insist on it, but you are not necessarily encouraged to use it. In particular, if you mix SQL and meta-commands on a line the order of execution might not always be clear to the inexperienced user.

`-t`  
`--tuples-only`

Turn off printing of column names and result row count footers, etc. This is equivalent to `\t` or `\pset tuples_only`.

``-T _`table_options`_``  
``--table-attr=_`table_options`_``

Specifies options to be placed within the HTML `table` tag. See `\pset tableattr` for details.

``-U _`username`_``  
``--username=_`username`_``

Connect to the database as the user _`username`_ instead of the default. (You must have permission to do so, of course.)

``-v _`assignment`_``  
``--set=_`assignment`_``  
``--variable=_`assignment`_``

Perform a variable assignment, like the `\set` meta-command. Note that you must separate name and value, if any, by an equal sign on the command line. To unset a variable, leave off the equal sign. To set a variable with an empty value, use the equal sign but leave off the value. These assignments are done during command line processing, so variables that reflect connection state will get overwritten later.

`-V`  
`--version`

Print the psql version and exit.

`-w`  
`--no-password`

Never issue a password prompt. If the server requires password authentication and a password is not available from other sources such as a `.pgpass` file, the connection attempt will fail. This option can be useful in batch jobs and scripts where no user is present to enter a password.

Note that this option will remain set for the entire session, and so it affects uses of the meta-command `\connect` as well as the initial connection attempt.

`-W`  
`--password`

Force psql to prompt for a password before connecting to a database, even if the password will not be used.

If the server requires password authentication and a password is not available from other sources such as a `.pgpass` file, psql will prompt for a password in any case. However, psql will waste a connection attempt finding out that the server wants a password. In some cases it is worth typing `-W` to avoid the extra connection attempt.

Note that this option will remain set for the entire session, and so it affects uses of the meta-command `\connect` as well as the initial connection attempt.

`-x`  
`--expanded`

Turn on the expanded table formatting mode. This is equivalent to `\x` or `\pset expanded`.

`-X,`  
`--no-psqlrc`

Do not read the start-up file (neither the system-wide `psqlrc` file nor the user's `~/.psqlrc` file).

`-z`  
`--field-separator-zero`

Set the field separator for unaligned output to a zero byte. This is equivalent to `\pset fieldsep_zero`.

`-0`  
`--record-separator-zero`

Set the record separator for unaligned output to a zero byte. This is useful for interfacing, for example, with `xargs -0`. This is equivalent to `\pset recordsep_zero`.

`-1`  
`--single-transaction`

This option can only be used in combination with one or more `-c` and/or `-f` options. It causes psql to issue a `BEGIN` command before the first such option and a `COMMIT` command after the last one, thereby wrapping all the commands into a single transaction. This ensures that either all the commands complete successfully, or no changes are applied.

If the commands themselves contain `BEGIN`, `COMMIT`, or `ROLLBACK`, this option will not have the desired effects. Also, if an individual command cannot be executed inside a transaction block, specifying this option will cause the whole transaction to fail.

`-?`  
``--help[=_`topic`_]``

Show help about psql and exit. The optional _`topic`_ parameter (defaulting to `options`) selects which part of psql is explained: `commands` describes psql's backslash commands; `options` describes the command-line options that can be passed to psql; and `variables` shows help about psql configuration variables.

## Exit Status

psql returns 0 to the shell if it finished normally, 1 if a fatal error of its own occurs (e.g., out of memory, file not found), 2 if the connection to the server went bad and the session was not interactive, and 3 if an error occurred in a script and the variable `ON_ERROR_STOP` was set.

## Usage

### Connecting to a Database

psql is a regular PostgreSQL client application. In order to connect to a database you need to know the name of your target database, the host name and port number of the server, and what user name you want to connect as. psql can be told about those parameters via command line options, namely `-d`, `-h`, `-p`, and `-U` respectively. If an argument is found that does not belong to any option it will be interpreted as the database name (or the user name, if the database name is already given). Not all of these options are required; there are useful defaults. If you omit the host name, psql will connect via a Unix-domain socket to a server on the local host, or via TCP/IP to `localhost` on machines that don't have Unix-domain sockets. The default port number is determined at compile time. Since the database server uses the same default, you will not have to specify the port in most cases. The default user name is your operating-system user name, as is the default database name. Note that you cannot just connect to any database under any user name. Your database administrator should have informed you about your access rights.

When the defaults aren't quite right, you can save yourself some typing by setting the environment variables `PGDATABASE`, `PGHOST`, `PGPORT` and/or `PGUSER` to appropriate values. (For additional environment variables, see [Section 33.14](https://www.postgresql.org/docs/10/app-psql.htmllibpq-envars.html "33.14. Environment Variables").) It is also convenient to have a `~/.pgpass` file to avoid regularly having to type in passwords. See [Section 33.15](https://www.postgresql.org/docs/10/app-psql.htmllibpq-pgpass.html "33.15. The Password File") for more information.

An alternative way to specify connection parameters is in a _`conninfo`_ string or a URI, which is used instead of a database name. This mechanism give you very wide control over the connection. For example:

```
$ psql "service=myservice sslmode=require"
$ psql postgresql://dbmaster:5433/mydb?sslmode=require
```

This way you can also use LDAP for connection parameter lookup as described in [Section 33.17](https://www.postgresql.org/docs/10/app-psql.htmllibpq-ldap.html "33.17. LDAP Lookup of Connection Parameters"). See [Section 33.1.2](https://www.postgresql.org/docs/10/app-psql.htmllibpq-connect.html#LIBPQ-PARAMKEYWORDS "33.1.2. Parameter Key Words") for more information on all the available connection options.

If the connection could not be made for any reason (e.g., insufficient privileges, server is not running on the targeted host, etc.), psql will return an error and terminate.

If both standard input and standard output are a terminal, then psql sets the client encoding to “auto”, which will detect the appropriate client encoding from the locale settings (`LC_CTYPE` environment variable on Unix systems). If this doesn't work out as expected, the client encoding can be overridden using the environment variable `PGCLIENTENCODING`.