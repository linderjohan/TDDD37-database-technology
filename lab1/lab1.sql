/*
 Lab 1 report <Oscar Olsson (oscol517) and Johan Linder (johli153)>
 */
/* All non code should be within SQL-comments like this */
/*
 Drop all user created tables that have been created when solving the lab
 
 
 DROP TABLE IF EXISTS custom_table CASCADE;-- 
 */
 DROP TABLE IF EXISTS budget_item CASCADE;
 DROP VIEW IF EXISTS budget_items CASCADE;
 DROP VIEW IF EXISTS cost_per_debit CASCADE;
/* Have the source scripts in the file so it is easy to recreate!*/
/*
 
 SOURCE company_schema.sql;
 SOURCE company_data.sql;
 
 */
 
/*
 Question 1: List all employees, i.e all tuples in the jbemployee relation
 */
SELECT * FROM jbemployee;

/*
 Execute:
 > SELECT * FROM jbemployee
 
 + ------- + --------- + ----------- + ------------ + -------------- + -------------- +
 | id      | name      | salary      | manager      | birthyear      | startyear      |
 + ------- + --------- + ----------- + ------------ + -------------- + -------------- +
 | 10      | Ross, Stanley | 15908       | 199          | 1927           | 1945           |
 | 11      | Ross, Stuart | 12067       |              | 1931           | 1932           |
 | 13      | Edwards, Peter | 9000        | 199          | 1928           | 1958           |
 | 26      | Thompson, Bob | 13000       | 199          | 1930           | 1970           |
 | 32      | Smythe, Carol | 9050        | 199          | 1929           | 1967           |
 | 33      | Hayes, Evelyn | 10100       | 199          | 1931           | 1963           |
 | 35      | Evans, Michael | 5000        | 32           | 1952           | 1974           |
 | 37      | Raveen, Lemont | 11985       | 26           | 1950           | 1974           |
 | 55      | James, Mary | 12000       | 199          | 1920           | 1969           |
 | 98      | Williams, Judy | 9000        | 199          | 1935           | 1969           |
 | 129     | Thomas, Tom | 10000       | 199          | 1941           | 1962           |
 | 157     | Jones, Tim | 12000       | 199          | 1940           | 1960           |
 | 199     | Bullock, J.D. | 27000       |              | 1920           | 1920           |
 | 215     | Collins, Joanne | 7000        | 10           | 1950           | 1971           |
 | 430     | Brunet, Paul C. | 17674       | 129          | 1938           | 1959           |
 | 843     | Schmidt, Herman | 11204       | 26           | 1936           | 1956           |
 | 994     | Iwano, Masahiro | 15641       | 129          | 1944           | 1970           |
 | 1110    | Smith, Paul | 6000        | 33           | 1952           | 1973           |
 | 1330    | Onstad, Richard | 8779        | 13           | 1952           | 1971           |
 | 1523    | Zugnoni, Arthur A. | 19868       | 129          | 1928           | 1949           |
 | 1639    | Choy, Wanda | 11160       | 55           | 1947           | 1970           |
 | 2398    | Wallace, Maggie J. | 7880        | 26           | 1940           | 1959           |
 | 4901    | Bailey, Chas M. | 8377        | 32           | 1956           | 1975           |
 | 5119    | Bono, Sonny | 13621       | 55           | 1939           | 1963           |
 | 5219    | Schwarz, Jason B. | 13374       | 33           | 1944           | 1959           |
 | NULL    | NULL      | NULL        | NULL         | NULL           | NULL           |
 + ------- + --------- + ----------- + ------------ + -------------- + -------------- +
 26 rows
 
 */
/* Question 2: List the name of all departments in alphabetial order. */
SELECT * FROM jbdept ORDER BY name;

/*
 
 Execute:
 > SELECT * FROM jbdept ORDER BY name
 
 + ------- + --------- + ---------- + ---------- + ------------ +
 | id      | name      | store      | floor      | manager      |
 + ------- + --------- + ---------- + ---------- + ------------ +
 | 1       | Bargain   | 5          | 0          | 37           |
 | 35      | Book      | 5          | 1          | 55           |
 | 10      | Candy     | 5          | 1          | 13           |
 | 73      | Children's | 5          | 1          | 10           |
 | 43      | Children's | 8          | 2          | 32           |
 | 19      | Furniture | 7          | 4          | 26           |
 | 99      | Giftwrap  | 5          | 1          | 98           |
 | 14      | Jewelry   | 8          | 1          | 33           |
 | 47      | Junior Miss | 7          | 2          | 129          |
 | 65      | Junior's  | 7          | 3          | 37           |
 | 26      | Linens    | 7          | 3          | 157          |
 | 20      | Major Appliances | 7          | 4          | 26           |
 | 58      | Men's     | 7          | 2          | 129          |
 | 60      | Sportswear | 5          | 1          | 10           |
 | 34      | Stationary | 5          | 1          | 33           |
 | 49      | Toys      | 8          | 2          | 35           |
 | 63      | Women's   | 7          | 3          | 32           |
 | 70      | Women's   | 5          | 1          | 10           |
 | 28      | Women's   | 8          | 2          | 32           |
 | NULL    | NULL      | NULL       | NULL       | NULL         |
 + ------- + --------- + ---------- + ---------- + ------------ +
 20 rows
 
 
 
 /* Question 3: What parts are not in store (quh = 0) */
SELECT * FROM jbparts WHERE qoh = 0;

/*
 
 Execute:
 > SELECT * FROM jbparts WHERE qoh = 0
 
 + ------- + --------- + ---------- + ----------- + -------- +
 | id      | name      | color      | weight      | qoh      |
 + ------- + --------- + ---------- + ----------- + -------- +
 | 11      | card reader | gray       | 327         | 0        |
 | 12      | card punch | gray       | 427         | 0        |
 | 13      | paper tape reader | black      | 107         | 0        |
 | 14      | paper tape punch | black      | 147         | 0        |
 | NULL    | NULL      | NULL       | NULL        | NULL     |
 + ------- + --------- + ---------- + ----------- + -------- +
 5 rows
 
 
 */
/* Question 4: Which employees have a salary between 9000 (included) and 10000(included) */
SELECT * FROM jbemployee WHERE salary >= 9000 AND salary <= 10000;

/*
 Execute:
 > SELECT * FROM jbemployee WHERE salary >= 9000 AND salary <= 10000
 
 + ------- + --------- + ----------- + ------------ + -------------- + -------------- +
 | id      | name      | salary      | manager      | birthyear      | startyear      |
 + ------- + --------- + ----------- + ------------ + -------------- + -------------- +
 | 13      | Edwards, Peter | 9000        | 199          | 1928           | 1958           |
 | 32      | Smythe, Carol | 9050        | 199          | 1929           | 1967           |
 | 98      | Williams, Judy | 9000        | 199          | 1935           | 1969           |
 | 129     | Thomas, Tom | 10000       | 199          | 1941           | 1962           |
 | NULL    | NULL      | NULL        | NULL         | NULL           | NULL           |
 + ------- + --------- + ----------- + ------------ + -------------- + -------------- +
 5 rows
 
 
 */
/* Question 5: What was the age of each employee when they started wokring (startyear)? */
SELECT id, name, (startyear - birthyear) AS age FROM jbemployee;

/*
 Execute:
 > SELECT id, name, (startyear - birthyear) AS age FROM jbemployee
 
 + ------- + --------- + -------- +
 | id      | name      | age      |
 + ------- + --------- + -------- +
 | 10      | Ross, Stanley | 18       |
 | 11      | Ross, Stuart | 1        |
 | 13      | Edwards, Peter | 30       |
 | 26      | Thompson, Bob | 40       |
 | 32      | Smythe, Carol | 38       |
 | 33      | Hayes, Evelyn | 32       |
 | 35      | Evans, Michael | 22       |
 | 37      | Raveen, Lemont | 24       |
 | 55      | James, Mary | 49       |
 | 98      | Williams, Judy | 34       |
 | 129     | Thomas, Tom | 21       |
 | 157     | Jones, Tim | 20       |
 | 199     | Bullock, J.D. | 0        |
 | 215     | Collins, Joanne | 21       |
 | 430     | Brunet, Paul C. | 21       |
 | 843     | Schmidt, Herman | 20       |
 | 994     | Iwano, Masahiro | 26       |
 | 1110    | Smith, Paul | 21       |
 | 1330    | Onstad, Richard | 19       |
 | 1523    | Zugnoni, Arthur A. | 21       |
 | 1639    | Choy, Wanda | 23       |
 | 2398    | Wallace, Maggie J. | 19       |
 | 4901    | Bailey, Chas M. | 19       |
 | 5119    | Bono, Sonny | 24       |
 | 5219    | Schwarz, Jason B. | 15       |
 + ------- + --------- + -------- +
 25 rows
 
 
 */
/* Question 6: Which employees have a last name ending with "son" ? */
SELECT * FROM jbemployee WHERE name LIKE '%son, %';

/*
 Execute:
 > SELECT * FROM jbemployee WHERE name LIKE '%son, %'
 
 + ------- + --------- + ----------- + ------------ + -------------- + -------------- +
 | id      | name      | salary      | manager      | birthyear      | startyear      |
 + ------- + --------- + ----------- + ------------ + -------------- + -------------- +
 | 26      | Thompson, Bob | 13000       | 199          | 1930           | 1970           |
 | NULL    | NULL      | NULL        | NULL         | NULL           | NULL           |
 + ------- + --------- + ----------- + ------------ + -------------- + -------------- +
 2 rows
 */
/* Question 7: Which items have been delivered by a supplier called "Fisher price" ?  */
SELECT * FROM jbitem WHERE supplier IN (SELECT id FROM jbsupplier WHERE name = "Fisher-Price");

/*
 Execute:
 > SELECT * FROM jbitem WHERE supplier IN (SELECT id FROM jbsupplier WHERE name = "Fisher-Price")
 
 + ------- + --------- + --------- + ---------- + -------- + ------------- +
 | id      | name      | dept      | price      | qoh      | supplier      |
 + ------- + --------- + --------- + ---------- + -------- + ------------- +
 | 43      | Maze      | 49        | 325        | 200      | 89            |
 | 107     | The 'Feel' Book | 35        | 225        | 225      | 89            |
 | 119     | Squeeze Ball | 49        | 250        | 400      | 89            |
 | NULL    | NULL      | NULL      | NULL       | NULL     | NULL          |
 + ------- + --------- + --------- + ---------- + -------- + ------------- +
 4 rows
 
 */
/* Question 8: Formulate the same query as above but without a subquery */
SELECT jbitem.id, jbitem.name, jbsupplier.name AS supplier
FROM jbitem
INNER JOIN jbsupplier ON jbitem.supplier = jbsupplier.id WHERE jbsupplier.name = "Fisher-Price";

/*
 Execute:
 > SELECT jbitem.id, jbitem.name, jbsupplier.name AS supplier FROM jbitem INNER JOIN jbsupplier ON jbitem.supplier = jbsupplier.id WHERE jbsupplier.name = "Fisher-Price"
 
 + ------- + --------- + ------------- +
 | id      | name      | supplier      |
 + ------- + --------- + ------------- +
 | 43      | Maze      | Fisher-Price  |
 | 107     | The 'Feel' Book | Fisher-Price  |
 | 119     | Squeeze Ball | Fisher-Price  |
 + ------- + --------- + ------------- +
 3 rows
 
 
 */
/* Question 9: Show all cities that have suppliers located in them. (with subquery) */
SELECT * FROM jbcity WHERE id IN (SELECT city FROM jbsupplier);

/*
 Execute:
 > SELECT * FROM jbcity WHERE id IN (SELECT city FROM jbsupplier)
 
 + ------- + --------- + ---------- +
 | id      | name      | state      |
 + ------- + --------- + ---------- +
 | 10      | Amherst   | Mass       |
 | 21      | Boston    | Mass       |
 | 100     | New York  | NY         |
 | 106     | White Plains | Neb        |
 | 118     | Hickville | Okla       |
 | 303     | Atlanta   | Ga         |
 | 537     | Madison   | Wisc       |
 | 609     | Paxton    | Ill        |
 | 752     | Dallas    | Tex        |
 | 802     | Denver    | Colo       |
 | 841     | Salt Lake City | Utah       |
 | 900     | Los Angeles | Calif      |
 | 921     | San Diego | Calif      |
 | 941     | San Francisco | Calif      |
 | 981     | Seattle   | Wash       |
 | NULL    | NULL      | NULL       |
 + ------- + --------- + ---------- +
 16 rows
 
 
 */
/* Question 10: What is the name and color of the parts that are heavier than a card reader? Formulate ths query using a subquery in the 
where-clause. (The query must not contain the weight as a constant) */

SELECT name, color, weight FROM jbparts WHERE weight > (SELECT weight FROM jbparts WHERE name = "card reader");

/*

Execute:
> SELECT name, color, weight FROM jbparts WHERE weight > (SELECT weight FROM jbparts WHERE name = "card reader")

+ --------- + ---------- + ----------- +
| name      | color      | weight      |
+ --------- + ---------- + ----------- +
| disk drive | black      | 685         |
| tape drive | black      | 450         |
| line printer | yellow     | 578         |
| card punch | gray       | 427         |
+ --------- + ---------- + ----------- +
4 rows





*/

/* Question 11: Formulate the query as above without subquery */
SELECT A.name, A.color, A.weight, B.weight AS card_reader_weight FROM jbparts A, jbparts B WHERE A.weight > B.weight AND B.name = 'card reader';

/*

Execute:
> SELECT A.name, A.color, A.weight, B.weight AS card_reader_weight FROM jbparts A, jbparts B WHERE A.weight > B.weight AND B.name = 'card reader'

+ --------- + ---------- + ----------- + ----------------------- +
| name      | color      | weight      | card_reader_weight      |
+ --------- + ---------- + ----------- + ----------------------- +
| disk drive | black      | 685         | 327                     |
| tape drive | black      | 450         | 327                     |
| line printer | yellow     | 578         | 327                     |
| card punch | gray       | 427         | 327                     |
+ --------- + ---------- + ----------- + ----------------------- +
4 rows



*/

/* Question 12: What is the average weight of black parts */

SELECT AVG(weight) AS average_weight FROM jbparts WHERE color = 'black';

/*

Execute:
> SELECT AVG(weight) AS average_weight FROM jbparts WHERE color = 'black'

+ ------------------- +
| average_weight      |
+ ------------------- +
| 347.2500            |
+ ------------------- +
1 rows

*/


/* Question 13: What is the total weight of all parts that each supplier in Massachusetts (“Mass”) has delivered?
								Retrieve the name and the total weight for each of these suppliers.
								Do not forget to take the quantity of delivered parts into account. 
								Note that one row should be returned for each supplier. */


SELECT s.name AS supplier_name, SUM(p.weight * supply.quan) AS total_weight FROM jbparts p
INNER JOIN jbsupply supply ON p.id = supply.part
INNER JOIN jbsupplier s ON supply.supplier = s.id
INNER JOIN jbcity c ON s.city = c.id
WHERE c.state = 'Mass'
GROUP BY supply.supplier;

/* 
Execute:
> SELECT s.name AS supplier_name, SUM(p.weight * supply.quan) AS total_weight FROM jbparts p
INNER JOIN jbsupply supply ON p.id = supply.part
INNER JOIN jbsupplier s ON supply.supplier = s.id
INNER JOIN jbcity c ON s.city = c.id
WHERE c.state = 'Mass'
GROUP BY supply.supplier

+ ------------------ + ----------------- +
| supplier_name      | total_weight      |
+ ------------------ + ----------------- +
| Fisher-Price       | 1135000           |
| DEC                | 3120              |
+ ------------------ + ----------------- +
2 rows 
*/


/* Question 14: Create a new relation (a table), with the same attributes as the table items using
						the CREATE TABLE syntax where you define every attribute explicitly (i.e. not
						as a copy of another table). Then fill the table with all items that cost less than the
						average price for items. Remember to define primary and foreign keys in your
						table! */


CREATE TABLE budget_item (
	id INT NOT NULL,
	name VARCHAR(20),
	dept INT NOT NULL,
	price INT,
	qoh INT UNSIGNED,
	supplier INT NOT NULL,
	CONSTRAINT pk_budget_item PRIMARY KEY(id),
	CONSTRAINT fk_budget_item_dept FOREIGN KEY(dept) REFERENCES jbdept(id),
	CONSTRAINT fk_budget_item_supplier FOREIGN KEY(supplier) REFERENCES jbsupplier(id))
	ENGINE=InnoDB;


/*
Execute:
> 	CREATE TABLE budget_item (
	id INT NOT NULL,
	name VARCHAR(20),
	dept INT NOT NULL,
	price INT,
	qoh INT UNSIGNED,
	supplier INT NOT NULL,
	CONSTRAINT pk_budget_item PRIMARY KEY(id),
	CONSTRAINT fk_budget_item_dept FOREIGN KEY(dept) REFERENCES jbdept(id),
	CONSTRAINT fk_budget_item_supplier FOREIGN KEY(supplier) REFERENCES jbsupplier(id))
	ENGINE=InnoDB;

0 row(s) affected 
0.031 sec

 */

INSERT INTO budget_item 
SELECT * FROM jbitem i
WHERE i.price < (SELECT AVG(jbitem.price) FROM jbitem);


/* 
Execute: 
> INSERT INTO budget_item 
SELECT * FROM jbitem i
WHERE i.price < (SELECT AVG(jbitem.price) FROM jbitem);

14 row(s) affected Records: 14  Duplicates: 0  Warnings: 0
0.015 sec
*/


/* Question 15: Create a view that contains the items that cost less than the average price for
					 items. */

CREATE VIEW budget_items AS SELECT * FROM budget_item;

/* 
Execute: 
>CREATE VIEW budget_items AS SELECT * FROM budget_item;

0 row(s) affected
0.016 sec
 
*/


/* Question 16: What is the difference between a table and a view? One is static and the other is
					 dynamic. Which is which and what do we mean by static respectively dynamic? */


/* A view is virtual table that is based on the result of a SQL-statement, like a SELECT. It contains no actual data,
but has columns and rows just like a table. A view is a definition that is built on top of other tables (or views).
If data are changing in som of the tables the view are built on, the view reflects those changes. Therefore Views are 
dynamic.  

The table is considered static since it access data that is stored physically.
 */


/* Question 17: Create a view that calculates the total cost of each debit, by considering price and
					 quantity of each bought item. (To be used for charging customer accounts). The
					 view should contain the sale identifier (debit) and total cost. Use only the implicit
					 join notation, i.e. only use a where clause but not the keywords inner join, right
					 join or left join, */

CREATE VIEW cost_per_debit AS 
SELECT d.id, s.quantity * i.price AS total_price 
FROM jbdebit d, jbsale s, jbitem i 
WHERE d.id = s.debit 
AND s.item = i.id
GROUP BY d.id;

/* 
Execute:
> CREATE VIEW cost_per_debit AS 
SELECT d.id, s.quantity * i.price AS total_price 
FROM jbdebit d, jbsale s, jbitem i 
WHERE d.id = s.debit 
AND s.item = i.id
GROUP BY d.id;

0 row(s) affected
0.015 sec
*/

SELECT * FROM cost_per_debit;

/* 
Execute:
> SELECT * FROM cost_per_debit

+ ------- + ---------------- +
| id      | total_price      |
+ ------- + ---------------- +
| 100581  | 1250             |
| 100582  | 1000             |
| 100586  | 396              |
| 100592  | 650              |
| 100593  | 430              |
| 100594  | 3295             |
+ ------- + ---------------- +
6 rows
*/


/* Question 18: Do the same as in (17), using only the explicit join notation, i.e. using only left,
					 right or inner joins but no join condition in a where clause. Motivate why you use
					 the join you do (left, right or inner), and why this is the correct one (unlike the
					 others). */

DROP VIEW cost_per_debit;

CREATE VIEW cost_per_debit AS
SELECT d.id, s.quantity * i.price AS total_price 
FROM jbdebit d 
INNER JOIN jbsale s ON d.id = s.debit
INNER JOIN jbitem i ON s.item = i.id
GROUP BY d.id;

/* 
Execute:
> CREATE VIEW cost_per_debit AS
SELECT d.id, s.quantity * i.price AS total_price 
FROM jbdebit d 
INNER JOIN jbsale s ON d.id = s.debit
INNER JOIN jbitem i ON s.item = i.id
GROUP BY d.id;

0 row(s) affected
0.016 sec
*/

SELECT * FROM cost_per_debit;

/* 
Execute:
> SELECT * FROM cost_per_debit

+ ------- + ---------------- +
| id      | total_price      |
+ ------- + ---------------- +
| 100581  | 1250             |
| 100582  | 1000             |
| 100586  | 396              |
| 100592  | 650              |
| 100593  | 430              |
| 100594  | 3295             |
+ ------- + ---------------- +
6 rows

Answer:
	We used INNER JOIN since we wanted to calculate the total price from the joined records.
	With INNER JOIN, we will never recieve NULL values from the join. However, any other JOIN may 
	respond with NULL values where the join condition is false. */


/* Question 19: Oh no! An earthquake!
a) Remove all suppliers in Los Angeles from the table jbsupplier. This will not
work right away (you will receive error code 23000) which you will have to
solve by deleting some other related tuples. However, do not delete more
tuples from other tables than necessary and do not change the structure of the
tables, i.e. do not remove foreign keys. Also, remember that you are only
allowed to use “Los Angeles” as a constant in your queries, not “199” or
“900”.*/




/* Delete all records in sale that are related to primary key in item where item is sold in Los Angeles */
DELETE s FROM jbsale s 
WHERE s.item IN (SELECT i.id FROM jbitem i 
WHERE i.supplier = (SELECT s.id FROM jbsupplier s 
WHERE s.city = (SELECT c.id FROM jbcity c 
WHERE c.name = "Los Angeles")));	

/* 
Execute: 
> DELETE s FROM jbsale s 
WHERE s.item IN (SELECT i.id FROM jbitem i 
WHERE i.supplier = (SELECT s.id FROM jbsupplier s 
WHERE s.city = (SELECT c.id FROM jbcity c 
WHERE c.name = "Los Angeles")));	

1 row(s) affected
0.015 sec
*/

/* Delete all records in item that are related to primary key in supplier where supplier city is Los Angeles */
DELETE i FROM jbitem i WHERE i.supplier = (SELECT s.id FROM jbsupplier s WHERE s.city = (SELECT c.id FROM jbcity c WHERE c.name = "Los Angeles"));

/* Execute: > DELETE i FROM jbitem i WHERE i.supplier = (SELECT s.id FROM jbsupplier s WHERE s.city = (SELECT c.id FROM jbcity c WHERE c.name = "Los Angeles"));
	2 row(s) affected	
	0.015 sec
*/

/* Delete all records in budget_item that are related to primary key in supplier where supplier city is Los Angeles */
DELETE b FROM budget_item b WHERE b.supplier = (SELECT s.id FROM jbsupplier s WHERE s.city = (SELECT c.id FROM jbcity c WHERE c.name = "Los Angeles"));

/* Execute: > DELETE b FROM budget_item b WHERE b.supplier = (SELECT s.id FROM jbsupplier s WHERE s.city = (SELECT c.id FROM jbcity c WHERE c.name = "Los Angeles")); 
	1 row(s) affected
	0.016 sec
*/

/* Delete all records in supplier which is located in Los Angeles*/
DELETE s FROM jbsupplier s
WHERE s.city = (SELECT c.id FROM jbcity c WHERE c.name = "Los Angeles");

/* Execute: 
> DELETE s FROM jbsupplier s
WHERE s.city = (SELECT c.id FROM jbcity c WHERE c.name = "Los Angeles");  
1 row(s) affected
0.016 sec
*/

/*b) Explain what you did and why */
/* 
	We needed to remove all record with foreign keys refering to record we wanted to remove in jbsupplier.

	We started with records which has foreign keys connect to it, since these can be removed directly.
	We removed records in jbsale first.

	Then we could remove records in he "partent" to jbsale, jbitem.

	Next, we needed to remove the two another "child" to supplier, jbsupply and our own table budget_items.

	When all records referring to the record we want to remove, the suppliers located in Los Angeles could finally be removed.
 */
