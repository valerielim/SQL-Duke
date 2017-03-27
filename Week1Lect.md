# Week 1: Introduction to Databases

### Background
##### What is SQL? Why do we need it?
* SQL = Structured Query Language
* SQL is used by every relational database (DB) management system, or DBMS.
* It lets us efficiently store and extract large amounts of data

> Prof: "Imagine that you have multiple users trying to access the same excel workbook/ data spreadsheet. It is going to lag like hell. Now multiply that problem by 1000. Holy crap. This is why we need a database system, so we don't go crazy."

- Other DBs will also use a language _based on_ SQL (e.g., MySQL, PostGres)
- Once you learn how to use the general SQL language, it will be easy to switch between systems
- Same as driving a car - once you know how to drive one car, you can switch with relative ease between different car brands :) 
    
##### What are relational databases?

* It is something  awesome
* Officially, a relational database is "a database structured to _recognize relations_ between stored items of information"
* Basically, recognising relations between stored items helps it only extract items that are absolutely needed, reducing run-time
* (You guessed it!-) Made from set theory. 
> Summary: Only interacts with subsets of data it needs to provide the information you asked, rather than opening an entire excel sheet

##### Benefits
* More memory efficient for large datasets
* Faster responses to queries too!
* Having structure can prevent or minimises data overrides
* Supports greater data entry accuracy, can specify what data type is allowed per field (eg. only numbers) 

##### Basic Features
- Tables = smallest logical subset
- Columns = must be unique
- Order of column & rows MUST NOT matter. So db can retrieve information in whatever order or fashion it determines to be the fastest.

##### About the Field/ Course
- We will generally focus on making queries
- Only early-stage startups need to set up or maintain the db
- This course will mostly cover how to make queries, but not how to make a DB

> Alright hotstuff. In case you're wondering/forgot, why bother with diagrams? 
>
> Because understanding how a db is laid out helps greatly with learning to write queries later. 
> Now let's get started!

-----

# ER Diagrams
### Entitles
- Shape: boxes
- Each box = one category, possibly a table
- Each box is called an entity instance
- Every entity must have at least one column that serves as a UA or unique key identifier (see next section for UA)

### Attributes
- Shape: circles
- Each circle = one attribute of a box, or an attribute of an entity. 

**Unique Attribute**
- A Unique Attribute or a Primary Key is an attribute with a unique value in each entity instance.
- Underline the UA
- This is the column that allows you to link to the master table together
- Eg. Student IDs are unique for every student

**Composite Attribute**
- Composite attributes are those that can be completely reconstructed using other entities
- Eg. Classroom ID = building ID + room unit no.
- Usually, the composite attribute itself (aka the final product) is not included in main DB to save space. Only its parts are included in the DB. 

**Examples of composite attribute**
- Classroom is the entity
- Identified by "classroomID" value
- All classroom IDs will have a building and room number attribute attached to it

### Relationships 
- ---- lines between entities
- < > diamonds to describe relationship

### Cardinality constraints
- Describe the minimum (min) or maximum (max) number of items the other entity can be linked to. 
- Bracket notes: always written left to right even if diagram orientation or page orientation is right to left.
    - M = infinite
    - O = optional.
- Lines closest to rectangle: MAXIMUM no. of instances associated with that entity
- Lines furthest away: MINIMUM no. of instances associated with that entity
    - --- straight line = single
    - / >  crows feet = many

**Examples of cardinality constraints**

- Each college can be attended by (max) multiple students, but it attended by (min) at least one student. (M, 1)
- Each student attends (max) one college, or (min) one college. (1, 1)
- (10, 1000) = each college needs a minimum of 10 students, max of 1000 students.

### Weak Entitles
- Weak entities will not be identifiable on their own (not fully unique like a full entity)
- Weak entities have double outline
- Can be combined with another weak entity to form a fully unique key
- ----- Dotted underline title means that attribute is a partial key

**Example: Building & apartment IDs**

- Building ID is the unique primary key
- Partial key (Apartment ID) can become full unique key (equivalent of building ID) IF it is connected to the unique key of the entity it is connected to with the unique double-diamond ID.
- Apartment ID is only unique if combined with Building ID.

# Relational Schemas

- Similar items but new names:
    - tables (or "relation")
    - columns ("fields" / "attributes")
    - row ("record" / "tuple")
- An RS is a simplified version (or plan for) a db
- Reflects logical ideas, but NOT physical (actual) design
- Strictly no order, variables must be independent
- Benefit: Looks less messy lol
- Problem: they lack cardinality constraints in ER diagrams. So sometimes one value matches to more than one key, but you won't know this until you see the ER diagram too.

### PRIMARY KEY (PK)
- Each table = one box
- PK should be underlined and put at top of box.
    - The PK must have a value unique for every row in that table.
    - PK strictly CANNOT have null values.
- Columns that can double up as primary keys, because they also have unique values, can be marked with a (U)

### FOREIGN KEY (FK)
- Columns that refer to the primary key of another table
- Write (FK) next to item to highlight its status
- Draw arrows to new table it refers to.

### WEAK ENTITIES
- Will have TWO underlined keys, could be their own partial key paired with a foreign key. aka their own key paired with the primary key of another table
- Together, this composite key forms a primary key.

### MANY TO MANY RELATIONSHIP
- Clue that columns can have many instances of one another
- For example, many classes can have combinations of many students
- Usually, primary keys must not be duplicated. But in a many-to-many relationship, an exception is made to illustrate the relationship.
- So, this table has nothing but 2 foreign keys in it making 1 composite primary key

# Conclusion: Building ERD diagrams
- Using ERDPlus tool to make diagrams
- www.erdplus.com
- Can export diagrams as images
