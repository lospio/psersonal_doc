---
April 10, 2023
---
# The Complete Oracle to Postgres Migration Guide: Move and Convert Schema, Applications and Data

![rw-book-cover](https://www.enterprisedb.com/sites/default/files/edb-og-default-image.jpg)

## Metadata
- Author: [[Raghavendra Rao]]
- Full Title: The Complete Oracle to Postgres Migration Guide: Move and Convert Schema, Applications and Data
- Category: #articles
- URL: https://www.enterprisedb.com/blog/the-complete-oracle-to-postgresql-migration-guide-tutorial-move-convert-database-oracle-alternative

## Highlights
- Server resources (memory/disk space/network ports opened between source and destination) ([View Highlight](https://read.readwise.io/read/01gx35dt2zmgccprearp6b30qh))
- Operating system ([View Highlight](https://read.readwise.io/read/01gx35dxvg264dph4fggf9wbfc))
- Data migration software and related drivers installed and configured ([View Highlight](https://read.readwise.io/read/01gx35e1tkxmsa50hjcqqa9gm7))
- What are the Oracle to Postgres schema migration tools? ([View Highlight](https://read.readwise.io/read/01gx360nhjr7anap6rvp991wjx))
- Postgres does not require the FROM clause, so FROM DUAL is not necessary and can usually be omitted. ([View Highlight](https://read.readwise.io/read/01gx36xzn4vx7b8z3t861tebek))
- In Oracle, empty strings have NULL values, but they are not considered NULL in Postgres. ([View Highlight](https://read.readwise.io/read/01gx36yfgdh2657nfs3h61vykf))
- In Oracle, you can check whether a string is empty or not using the IS NULL operator, but in Postgres, it would return FALSE for an empty string (and TRUE for a NULL one). ([View Highlight](https://read.readwise.io/read/01gx36z7q4yes6v65t4rmvwgqy))
- Not all privileges that are grantable in Oracle are grantable in Postgres ([View Highlight](https://read.readwise.io/read/01gx3717620js2wgcszyfr9g5k))
- Postgres does not support the START WITH . . . CONNECT BY syntax that Oracle uses for hierarchical queries. Instead, Postgres uses WITH RECURSIVE. ([View Highlight](https://read.readwise.io/read/01gx371yvq13y39mbh4jr44cc7))
- Oracle has a special shorthand (+) operator for performing left and right outer joins. Postgres lacks this feature, so the JOIN command would need to be supplied. ([View Highlight](https://read.readwise.io/read/01gx3747k0r0qby1y843yqq0yc))
- NOT NULL checking ([View Highlight](https://read.readwise.io/read/01gx3759vvcwyw8t3c6zgzsw6w))
- Postgres does not have an exact equivalent to the ROWID pseudocolumn in Oracle, which provides the address of a row in a table. ([View Highlight](https://read.readwise.io/read/01gx3788sedyakz8xncywn26fb))
- CTID in Postgres is similar, except that its value changes every time VACUUM is performed. ([View Highlight](https://read.readwise.io/read/01gx3783dbrrrp3n6pqeb7p90j))
- Instead, you can use identity columns, whose value is self-generated when a row is created and never changes. ([View Highlight](https://read.readwise.io/read/01gx378rhpn97b56tmqyrsnt5x))
- Sequences ([View Highlight](https://read.readwise.io/read/01gx379q8zjhdwhjwe92jpwanv))
- The Orafce migration tool includes a SUBSTR function that returns the same result in both databases. ([View Highlight](https://read.readwise.io/read/01gx37bynbrmqfh34b9j1hgpsd))
- Postgres does not support synonyms. In place of Oracle’s CREATE SYNONYM for accessing remote objects, Postgres has you use SET search_path to include the remote definition. ([View Highlight](https://read.readwise.io/read/01gx37c98x1w923qgyntxa5dh2))
- Postgres' date data type provides the date (year, month, day), while Oracle’s date data type value provides the date and time (year, month, day, hour, minute, second). To avoid this incompatibility, use Postgres' to_timestamp(). ([View Highlight](https://read.readwise.io/read/01gx37dkj1xqd7npp21d686bda))
- Orafce tool ([View Highlight](https://read.readwise.io/read/01gx37e2hftfyp39wcd0qnzeq4))
## New highlights added April 11, 2023 at 11:38 AM
- When preparing for schema conversion, pay special attention to the following differences between Oracle and Postgres. ([View Highlight](https://read.readwise.io/read/01gxn73eprmn9me6wh88ks7az1))
- Oracle’s virtual columns. ([View Highlight](https://read.readwise.io/read/01gxn75hm6dj1zddp6tyzhhhkb))
- Identifiers when migrating from Oracle to Postgres ([View Highlight](https://read.readwise.io/read/01gxn790jgtd3fz9g9x2ckr0tq))
- Reverse key, bitmap, and join indexes are not currently supported. ([View Highlight](https://read.readwise.io/read/01gxn7dd44b6addqdsycws8nrr))
- Global index is not supported in Postgres ([View Highlight](https://read.readwise.io/read/01gxn7a9h6ze1vptrqw4ntsmbr))
- global temporary tables ([View Highlight](https://read.readwise.io/read/01gxn7f1689jmzhcf00v08hsq2))
- Partitioning:  Use Inheritance, Triggers, and CHECK Constraints for partition clauses. ([View Highlight](https://read.readwise.io/read/01gxn7fzm97qc4yvxdjzza32ga))
- Storage clause parameters (INITRANS, MAXEXTENTS) are not recognized in Postgres and should be removed. ([View Highlight](https://read.readwise.io/read/01gxn7hhevxptbrnxbs6kv4znf))
- For the Oracle PCTFREE parameter, replace it with Postgres' fillfactor ([View Highlight](https://read.readwise.io/read/01gxn7j46tqdzajnb73hcqx4ha))
- The following chart lists notable differences between Oracle and Postgres data types. ([View Highlight](https://read.readwise.io/read/01gxn7n419k39h47d2xq71nkwy))
- SET CONSTRAINTS ([View Highlight](https://read.readwise.io/read/01gxn7pek655atpyyzqh2c67fj))
- Oracle’s Federation feature allows users to treat tables from other databases as local data. Postgres' foreign data wrappers are more versatile and allow you to connect to a wider range of data. ([View Highlight](https://read.readwise.io/read/01gxn7wdfdnk3wf09w336vktd8))
- PL/SQL to PL/pgSQL Conversion ([View Highlight](https://read.readwise.io/read/01gxn7ysmtnayh01cbjky1dnb7))
- 17) SYSDATE ([View Highlight](https://read.readwise.io/read/01gxn80fta72qew1fdscpycxa4))
