---
March 8, 2023
---
# Pg_dumpall version 10

![rw-book-cover](https://www.postgresql.org/media/img/about/press/elephant.png)

## Metadata
- Author: [[PostgreSQL Documentation]]
- Full Title: Pg_dumpall
- Category: #articles
- URL: https://www.postgresql.org/docs/10/app-pg-dumpall.html

## Highlights
- Since pg_dumpall reads tables from all databases you will most likely have to connect as a database superuser in order to produce a complete dump. ([View Highlight](https://read.readwise.io/read/01gtznjmnvgm5n4apa82hwskgz))
- pg_dumpall needs to connect several times to the PostgreSQL server (once per database). ([View Highlight](https://read.readwise.io/read/01gtzndhyh52t14sen0vq1p6sf))
- `-a` 
  `--data-only`
  Dump only the data, not the schema (data definitions). ([View Highlight](https://read.readwise.io/read/01gtzxkaq9jtm29jmgypmszfrf))
- ``-f *`filename`*`` 
  ``--file=*`filename`*``
  Send output to the specified file. If this is omitted, the standard output is used. ([View Highlight](https://read.readwise.io/read/01gtzxrteh08a7w7xhhgw8qqbq))
- `-s` 
  `--schema-only`
  Dump only the object definitions (schema), not data. ([View Highlight](https://read.readwise.io/read/01gtzxt9kx47k8e2xeg26f8417))
- `-v` 
  `--verbose`
  Specifies verbose mode. This will cause pg_dumpall to output start/stop times to the dump file, and progress messages to standard error. It will also enable verbose output in pg_dump. ([View Highlight](https://read.readwise.io/read/01gtzxvhn335zkkk0q0d1fmjxn))
- ``--lock-wait-timeout=*`timeout`*``
  Do not wait forever to acquire shared table locks at the beginning of the dump. Instead, fail if unable to lock a table within the specified *`timeout`*. ([View Highlight](https://read.readwise.io/read/01gtzxzmxgdd6wzy5k6254gja1))
- `--no-sync`
  By default, `pg_dumpall` will wait for all files to be written safely to disk. This option causes `pg_dumpall` to return without waiting, which is faster, but means that a subsequent operating system crash can leave the dump corrupt. Generally, this option is useful for testing but should not be used when dumping data from production installation. ([View Highlight](https://read.readwise.io/read/01gtzy6y7sfg0y7ygbzdc09xd6))
- Force quoting of all identifiers. This option is recommended when dumping a database from a server whose PostgreSQL major version is different from pg_dumpall's, or when the output is intended to be loaded into a server of a different major version. ([View Highlight](https://read.readwise.io/read/01gtzy8bexp1xw4qtp9bje2tqb))
- or when the output is intended to be loaded into a server of a different major version. ([View Highlight](https://read.readwise.io/read/01gtzy90xxyg8nxd3n1a8qyr1d))
- `-w` 
  `--no-password`
  Never issue a password prompt. If the server requires password authentication and a password is not available by other means such as a `.pgpass` file, the connection attempt will fail. This option can be useful in batch jobs and scripts where no user is present to enter a password. ([View Highlight](https://read.readwise.io/read/01gtzycq3gykb4600wybwp6fmv))
- ``--role=*`rolename`*``
  Specifies a role name to be used to create the dump. This option causes pg_dumpall to issue a `SET ROLE` *`rolename`* command after connecting to the database. It is useful when the authenticated user (specified by `-U`) lacks privileges needed by pg_dumpall, but can switch to a role with the required rights. ([View Highlight](https://read.readwise.io/read/01gtzyex9pjj9ptcfs34casnrm))
  
---
March 8, 2023
---
# Pg_dumpall version 9.6

![rw-book-cover](https://www.postgresql.org/media/img/about/press/elephant.png)

## Metadata
- Author: [[PostgreSQL Documentation]]
- Full Title: Pg_dumpall
- Category: #articles
- URL: https://www.postgresql.org/docs/9.6/app-pg-dumpall.html

## Highlights
- It does this by calling [pg_dump](https://www.postgresql.org/docs/9.6/app-pgdump.html) for each database in a cluster. ([View Highlight](https://read.readwise.io/read/01gtzyhdn2f2zgw1gadm5th9rs))
- g_dumpall also dumps global objects that are common to all databases. (pg_dump does not save these objects.) ([View Highlight](https://read.readwise.io/read/01gtzyhkanfs4eps3hf0w6mb3e))
- This currently includes information about database users and groups, tablespaces, and properties such as access permissions that apply to databases as a whole. ([View Highlight](https://read.readwise.io/read/01gtzyjew0evw91ratp3g6pq9y))
- Since pg_dumpall reads tables from all databases you will most likely have to connect as a database superuser in order to produce a complete dump. ([View Highlight](https://read.readwise.io/read/01gtzyk8wk1j0evwxjshp0y6eb))
- pg_dumpall needs to connect several times to the PostgreSQL server (once per database). If you use password authentication it will ask for a password each time. It is convenient to have a ~/.pgpass file in such cases. See [Section 32.15](https://www.postgresql.org/docs/9.6/libpq-pgpass.html) for more information. ([View Highlight](https://read.readwise.io/read/01gtzym7hddn3rv1442g9j2kcy))
- -a 
  --data-only
  Dump only the data, not the schema (data definitions). ([View Highlight](https://read.readwise.io/read/01gtzyv1txq1ede38qn2dwjkwb))
- -f filename 
  --file=filename
  Send output to the specified file. If this is omitted, the standard output is used. ([View Highlight](https://read.readwise.io/read/01gtzyw0tf5hebdhkqqvcpgbqa))
- -O 
  --no-owner
  Do not output commands to set ownership of objects to match the original database. ([View Highlight](https://read.readwise.io/read/01gtzyyca6g7mdj1rskzbnrz7b))
- -r 
  --roles-only
  Dump only roles, no databases or tablespaces.
  -s 
  --schema-only
  Dump only the object definitions (schema), not data. ([View Highlight](https://read.readwise.io/read/01gtzyzckhq2vqwakcbvzmrexj))
- -v 
  --verbose
  Specifies verbose mode. This will cause pg_dumpall to output start/stop times to the dump file, and progress messages to standard error. It will also enable verbose output in pg_dump. ([View Highlight](https://read.readwise.io/read/01gtzz038dg8qcjw8r2va7f58m))
- --lock-wait-timeout=timeout
  Do not wait forever to acquire shared table locks at the beginning of the dump. Instead, fail if unable to lock a table within the specified timeout. The timeout may be specified in any of the formats accepted by SET statement_timeout. Allowed values vary depending on the server version you are dumping from, but an integer number of milliseconds is accepted by all versions since 7.3. This option is ignored when dumping from a pre-7.3 server. ([View Highlight](https://read.readwise.io/read/01gtzz3qe53ez3s6ypp1w8sq7z))
- --no-tablespaces
  Do not output commands to create tablespaces nor select tablespaces for objects. With this option, all objects will be created in whichever tablespace is the default during restore. ([View Highlight](https://read.readwise.io/read/01gtzz467r9k9971z692sq0r45))
- --quote-all-identifiers
  Force quoting of all identifiers. This option is recommended when dumping a database from a server whose PostgreSQL major version is different from pg_dumpall's, or when the output is intended to be loaded into a server of a different major version ([View Highlight](https://read.readwise.io/read/01gtzz4pd5nh2vghh4r3xccv8r))
## New highlights added March 11, 2023 at 3:43 PM
- The script file contains SQL commands that can be used as input to [psql](https://www.postgresql.org/docs/10/app-pg-dumpall.html/app-psql.html) to restore the databases. ([View Highlight](https://read.readwise.io/read/01gv4s1w3c8j5x9xz2pd4n5aaw))
- pg_dumpall also dumps global objects that are common to all databases. (pg_dump does not save these objects.) This currently includes information about database users and groups, tablespaces, and properties such as access permissions that apply to databases as a whole. ([View Highlight](https://read.readwise.io/read/01gv4sm6rbf61fg98jyz42t9pz))
