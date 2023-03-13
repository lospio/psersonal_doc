---
ctime: 2022-12-13 17:40
tags: simlpe-card
author: lche
alias: 
---
#vault-squirreldoc 

```sql
Do$$
DECLARE earliest DATE;
DECLARE latest DATE;
BEGIN
-- Set boundaries
SELECT min(totaldate) INTo earliest FROM dailytotals_legacy;
tatest :='2021-06-01'::DATE;

-- HACK HACK HACK (only because we know and trust our data)
ALTER TABLE dailytotals_legacy
ADD CONSTRAINT dailytotals_legacy_totaldate
CHECK (totaldate >= earliest AND totaldate < latest)
NOT VALID;

-- You should not touch pg_catalog directly
UPDATE pg_constraint
SET convalidated = true
WHERE conname ='dailytotals_legacy_totaldate';

ALTER TABLE dailytotals
ATTACH PARTITION dailytotals_legacy
FOR VALUES FROM (earliest) To (latest);
END;
$$ LANGUAGE PLPGSQL;
COMMIT;
```
 #### pg_constraint
- `convalidated` `bool`
Has the constraint been validated? Currently, can be false only for foreign keys and CHECK constraints

#### Alter  table add constraint [not valid]

This form adds a new constraint to a table using the same constraint syntax as [`CREATE TABLE`](dfile:///Users/lche/Library/Application%20Support/Dash/DocSets/PostgreSQL/PostgreSQL.docset/Contents/Resources/Documents/sql-createtable.html "CREATE TABLE"), plus the option `NOT VALID`, which is currently only allowed for foreign key and CHECK constraints.

Normally, ==this form will cause a scan of the table to verify that all existing rows in the table satisfy the new constraint.== 
==But if the `NOT VALID` option is used, this potentially-lengthy scan is skipped. The constraint will still be enforced against subsequent inserts or updates== (that is, they'll fail unless there is a matching row in the referenced table, in the case of foreign keys, or they'll fail unless the new row matches the specified check condition). ==But the database will not assume that the constraint holds for all rows in the table, until it is validated by using the `VALIDATE CONSTRAINT` option.== See [Notes](dfile:///Users/lche/Library/Application%20Support/Dash/DocSets/PostgreSQL/PostgreSQL.docset/Contents/Resources/Documents/sql-altertable.html#SQL-ALTERTABLE-NOTES "Notes") below for more information about using the `NOT VALID` option.

Although most forms of ``ADD _`table_constraint`_`` require an `ACCESS EXCLUSIVE` lock, `ADD FOREIGN KEY` requires only a `SHARE ROW EXCLUSIVE` lock. Note that `ADD FOREIGN KEY` also acquires a `SHARE ROW EXCLUSIVE` lock on the referenced table, in addition to the lock on the table on which the constraint is declared.

Additional restrictions apply when unique or primary key constraints are added to partitioned tables; see [`CREATE TABLE`](dfile:///Users/lche/Library/Application%20Support/Dash/DocSets/PostgreSQL/PostgreSQL.docset/Contents/Resources/Documents/sql-createtable.html "CREATE TABLE"). Also, foreign key constraints on partitioned tables may not be declared `NOT VALID` at present.


==Adding a `CHECK` or `NOT NULL` constraint requires scanning the table to verify that existing rows meet the constraint, but does not require a table rewrite.==

Similarly, ==when attaching a new partition it may be scanned to verify that existing rows meet the partition constraint.==

The main reason for providing the option to specify multiple changes in a single `ALTER TABLE` is that multiple table scans or rewrites can thereby be combined into a single pass over the table.

==Scanning a large table to verify a new foreign key or check constraint can take a long time, and other updates to the table are locked out until the `ALTER TABLE ADD CONSTRAINT` command is committed.== 
==The main purpose of the `NOT VALID` constraint option is to reduce the impact of adding a constraint on concurrent updates.== 
- With `NOT VALID`, the `ADD CONSTRAINT` command does not scan the table and can be committed immediately. 
- After that, a `VALIDATE CONSTRAINT` command can be issued to verify that existing rows satisfy the constraint. 
	- The validation step does not need to lock out concurrent updates, since it knows that other transactions will be enforcing the constraint for rows that they insert or update; ==only pre-existing rows need to be checked.== Hence, validation acquires only a `SHARE UPDATE EXCLUSIVE`lock on the table being altered. (If the constraint is a foreign key then a `ROW SHARE` lock is also required on the table referenced by the constraint.) In addition to improving concurrency, it can be useful to use `NOT VALID` and `VALIDATE CONSTRAINT` in cases where the table is known to contain pre-existing violations. Once the constraint is in place, no new violations can be inserted, and the existing problems can be corrected at leisure until `VALIDATE CONSTRAINT` finally succeeds.



#关联概念 
- [[Article@ PostgreSQL Documentation 15 5.4. Constraints]]


