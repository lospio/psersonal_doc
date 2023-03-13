---
March 8, 2023
---
# CMU 15-445/645 Database Systems (Fall 2022) :: Course Introduction & Relational Model

![rw-book-cover](https://readwise-assets.s3.amazonaws.com/static/images/article2.74d541386bbf.png)

## Metadata
- Author: [[Andy Pavlo]]
- Full Title: CMU 15-445/645 Database Systems (Fall 2022) :: Course Introduction & Relational Model
- Category: #articles
- URL: https://readwise.io/reader/document_raw_content/38725939

## Highlights
- FLAT FILES: DATA INTEGRITY
  How do we ensure that the artist is the same for
  each album entry?
  What if somebody overwrites the album year with
  an invalid string?
  What if there are multiple artists on an album?
  What happens if we delete an artist that has
  albums? ([View Highlight](https://read.readwise.io/read/01gtzghcmmqcg300nxyj189eqm))
- FLAT FILES: IMPLEMENTATION
  How do you find a particular record?
  What if we now want to create a new application
  that uses the same database?
  What if two threads try to write to the same file at
  the same time? ([View Highlight](https://read.readwise.io/read/01gtzghpvk4648k05xd72s6bh2))
- FLAT FILES: DURABILITY
  What if the machine crashes while our program is
  updating a record?
  What if we want to replicate the database on
  multiple machines for high availability? ([View Highlight](https://read.readwise.io/read/01gtzgnytcgy8yexbfdynhckfc))
- A database management system (DBMS) is
  software that allows applications to store and
  analyze information in a database. ([View Highlight](https://read.readwise.io/read/01gtzg3yzm9fzx4j0ay5hrkhyg))
- A general-purpose DBMS supports the definition,
  creation, querying, update, and administration of
  databases in accordance with some data model. ([View Highlight](https://read.readwise.io/read/01gtzg4jpdz06d9thy7qd4v0tt))
- A data model is a collection of concepts for
  describing the data in a database. ([View Highlight](https://read.readwise.io/read/01gtzg4qak65ccpsgghh6gey76))
- A schema is a description of a particular collection
  of data, using a given data model. ([View Highlight](https://read.readwise.io/read/01gtzg517nna4rxb1yhr8e6vt6))
- Tight coupling between logical and physical layers. ([View Highlight](https://read.readwise.io/read/01gtzgqng40w5npf1gs1zy6w4x))
- → Store database in simple data structures (relations).
  → Physical storage left up to the DBMS implementation.
  → Access data through high-level language, DBMS figures
  out best execution strategy. ([View Highlight](https://read.readwise.io/read/01gtzh0c9ad7ghqfwa3y8a9jxw))
- Structure: The definition of the database's
  relations and their contents. ([View Highlight](https://read.readwise.io/read/01gtzh1sdmwesv57940e6m314n))
- Integrity: Ensure the database's contents satisfy
  constraints. ([View Highlight](https://read.readwise.io/read/01gtzh1ztvk8ctnsza5m5aqb48))
- Manipulation: Programming interface for
  accessing and modifying a database's contents. ([View Highlight](https://read.readwise.io/read/01gtzh2708ppqcaj2atqw9gzf0))
- A relation is an unordered set that
  contain the relationship of attributes
  that represent entities. ([View Highlight](https://read.readwise.io/read/01gtzh4mje31521zfq7gk4sqrk))
- A tuple is a set of attribute values (also
  known as its domain) in the relation.
  → Values are (normally) atomic/scalar.
  → The special value NULL is a member of
  every domain (if allowed). ([View Highlight](https://read.readwise.io/read/01gtzh556a98rd2nf9ra6103f4))
- A relation's primary key uniquely
  identifies a single tuple. ([View Highlight](https://read.readwise.io/read/01gtzh6z8gs00qpz7nknkxqcxx))
- A foreign key specifies that an attribute from one
  relation has to map to a tuple in another relation. ([View Highlight](https://read.readwise.io/read/01gtzh91r6ttp5ps9zg7r6y0b9))
- Procedural:
  → The query specifies the (high-level) strategy
  to find the desired result based on sets / bags. ([View Highlight](https://read.readwise.io/read/01gtzhb35j28tv3dkhfdcdakqt))
- Non-Procedural (Declarative):
  → The query specifies only what data is wanted
  and not how to find it. ([View Highlight](https://read.readwise.io/read/01gtzhc5q5v9qee5mn31ph06xe))
- σ Select
  π Projection
  ∪ Union
  ∩ Intersection
  – Difference
  × Product
  ⋈ Join ([View Highlight](https://read.readwise.io/read/01gtzhqp604ckqqb4xwxdktt82))
- Generate a relation that contains only
  the tuples that appear in the first and
  not the second of the input relations. ([View Highlight](https://read.readwise.io/read/01gtzj82bx8609xkn3n07m0m0x))
- Syntax: (R – S) ([View Highlight](https://read.readwise.io/read/01gtzj848xsm8br7tcts19a1jt))
- Generate a relation that contains all
  possible combinations of tuples from
  the input relations. ([View Highlight](https://read.readwise.io/read/01gtzj8tg0nxfjf30ntwekdmgt))
- Syntax: (R × S)
  SELECT * FROM R CROSS JOIN S;
  SELECT * FROM R, S; ([View Highlight](https://read.readwise.io/read/01gtzj9b206x3497s51esnkr75))
- Generate a relation that contains all
  tuples that are a combination of two
  tuples (one from each input relation)
  with a common value(s) for one or
  more attributes. ([View Highlight](https://read.readwise.io/read/01gtzjawjw5m8jrmet2yf45yjy))
- Rename (ρ)
  Assignment (R←S)
  Duplicate Elimination (δ)
  Aggregation (γ)
  Sorting (τ)
  Division (R÷S) ([View Highlight](https://read.readwise.io/read/01gtzjc7yhbjnmqaphpqvapege))
- A better approach is to state the high-level answer
  that you want the DBMS to compute.
  → Retrieve the joined tuples from R and S where b_id
  equals 102. ([View Highlight](https://read.readwise.io/read/01gtzjfjay3ftg2yg04rtt1dc5))
- SQL is the de facto standard (many dialects). ([View Highlight](https://read.readwise.io/read/01gtzjjxaczpvrnq41zhbjpm4d))
## New highlights added March 11, 2023 at 3:43 PM
- Embed data hierarchy into a single object. ([View Highlight](https://read.readwise.io/read/01gv227284eysggtvmf6nh51af))
- Databases are ubiquitous. ([View Highlight](https://read.readwise.io/read/01gv228535vrme4e9snh8ec3e4))
