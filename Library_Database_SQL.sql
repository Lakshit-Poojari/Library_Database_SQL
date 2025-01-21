Create Table branch
	(
		branch_id Varchar(20) PRIMARY KEY,
		manager_id Varchar(20),
		branch_address Varchar(50),	
		contact_no Varchar(20)
	)

Create Table employees
	(
		emp_id Varchar(20) PRIMARY KEY, 
		emp_name Varchar(20),
		position Varchar(20),
		salary INT,
		branch_id Varchar(20)
	)

alter table employees
alter column salary type float
	
Create Table books
	(
		isbn Varchar(20) PRIMARY KEY,
		book_title	Varchar(70),
		category	Varchar(20),
		rental_price	float,
		status	Varchar(20),
		author	Varchar(50),
		publisher Varchar(50)
	)

ALTER TABLE books
ADD CONSTRAINT pk_isbn PRIMARY KEY (isbn);
	
create table issued_status
	(
		issued_id Varchar(20) PRIMARY KEY,
		issued_member_id Varchar(20),
		issued_book_name Varchar(70),
		issued_date date,
		issued_book_isbn Varchar(50),
		issued_emp_id Varchar(20)
	)

create table members
	(
		member_id varchar(20) PRIMARY KEY,
		member_name varchar(50),
		member_address varchar(75),
		reg_date date
	)

create table return_status
	(
		return_id varchar(20) PRIMARY KEY,
		issued_id varchar(20),
		return_book_name varchar(80),
		return_date date,
		return_book_isbn varchar(20)
	)
	
select * from branch
select * from employees
select * from books
select * from issued_status
select * from members
select * from return_status

	
--Creating Foreign key
ALTER TABLE issued_status
ADD CONSTRAINT fk_members
FOREIGN KEY (issued_member_id)
REFERENCES members(member_id);

--Creating Foreign key
ALTER TABLE issued_status
ADD CONSTRAINT fk_books
FOREIGN KEY (issued_book_isbn)
REFERENCES books(isbn);

--Creating Foreign key
ALTER TABLE issued_status
ADD CONSTRAINT fk_employees
FOREIGN KEY (issued_emp_id)
REFERENCES employees(emp_id);

--Creating Foreign key
ALTER TABLE employees
ADD CONSTRAINT fk_branch
FOREIGN KEY (branch_id)
REFERENCES branch(branch_id);

--Creating Foreign key
ALTER TABLE return_status
ADD CONSTRAINT fk_issued_status
FOREIGN KEY (issued_id)
REFERENCES issued_status(issued_id);


-- Deleted this data because it does not exist in issued_status Table
DELETE FROM return_status
WHERE   issued_id =   'IS101';

-- Deleted this data because it does not exist in issued_status Table
DELETE FROM return_status
WHERE   issued_id =   'IS105';

-- Deleted this data because it does not exist in issued_status Table
DELETE FROM return_status
WHERE   issued_id =   'IS103';

/*Create a New Book Record -- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic',
6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"*/
INSERT INTO books (isbn, book_title , category, rental_price, status, author, publisher )
VALUES ('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee',
	'J.B. Lippincott & Co.')

/*Update an Existing Member's Address*/
UPDATE members
Set member_address = '012 Main St'
WHERE member_id = 'C101'

/*Delete a Record from the Issued Status Table -- Objective: 
Delete the record with issued_id = 'IS121' from the issued_status table.*/
DELETE FROM issued_status
WHERE issued_id = 'IS121'

/*Retrieve All Books Issued by a Specific Employee -- Objective: 
Select all books issued by the employee with emp_id = 'E101'.*/
SELECT issued_book_name FROM issued_status
WHERE issued_emp_id = 'E101'

/*List Members Who Have Issued More Than One Book -- Objective: 
Use GROUP BY to find members who have issued more than one book.*/
select issued_emp_id, count(*) as Number_of_issued_book from issued_status
	group by (issued_emp_id)
	having count(*)>=2
	order by Number_of_issued_book DESC

/*Retrieve All Books in a Specific Category*/
SELECT Category FROM books
	GROUP BY (category)
	
SELECT * FROM books
WHERE category = 'Classic'

SELECT * FROM books
WHERE category = 'Literary Fiction'

SELECT * FROM books
WHERE category = 'History'
	
SELECT * FROM books
WHERE category = 'Fantasy'

SELECT * FROM books
WHERE category = 'Dystopian'

SELECT * FROM books
WHERE category = 'Horror'

SELECT * FROM books
WHERE category = 'Mystery'

SELECT * FROM books
WHERE category = 'Children'

SELECT * FROM books
WHERE category = 'Science Fiction'

SELECT * FROM books
WHERE category = 'Fiction'

/*Find Total Rental Income by Category*/
SELECT b.Category, SUM(b.rental_price) AS Total_Rental_Price, COUNT(ist.*) as Total_Book_Issued 
FROM books as b
	JOIN issued_status as ist
		ON b.isbn =  ist.issued_book_isbn
	GROUP BY (b.category)
	ORDER BY Total_Rental_Price DESC

/*List Members Who Registered in the Last 480 Days*/
SELECT * FROM members
WHERE reg_date >= CURRENT_DATE - INTERVAL '480 days';

/*List Employees with Their Branch Manager's Name and their branch details*/
SELECT e.emp_id, e.emp_name, e1.emp_name as manager_name, e.position, e.salary, b.* FROM employees as e
	JOIN branch as b
		ON e.branch_id = b.branch_id
	JOIN employees as e1
		on e1.emp_id = b.manager_id

/*Create a Table of Books with Rental Price Above a Certain Threshold*/
SELECT * from books
WHERE rental_price >= 7
ORDER BY rental_price DESC

/*Retrieve the List of Books Not Yet Returned*/
SELECT * FROM issued_status as ist
LEFT JOIN
return_status as rs
ON rs.issued_id = ist.issued_id
WHERE rs.return_id IS NULL;

/*Identify Members with Overdue Books
Write a query to identify members who have overdue books (assume a 60-day return period). 
Display the member's_id, member's name, book title, issue date, and days overdue.*/
SELECT ist.issued_member_id, m.member_name,  bk.book_title, ist.issued_date, rst.return_date, 
	(rst.return_date - ist.issued_date) as days_difference FROM issued_status  as  ist
JOIN members as m
on
m.member_id = ist.issued_member_id

LEFT JOIN return_status as rst
on
rst.issued_id = ist.issued_id

JOIN books as bk
ON bk.isbn = ist.issued_book_isbn
	
WHERE (rst.return_date - ist.issued_date) > 60 or (rst.return_date - ist.issued_date) is null
ORDER BY days_difference
	
/*Branch Performance Report
Create a query that generates a performance report for each branch, 
showing the number of books issued, the number of books returned, 
and the total revenue generated from book rentals.*/
Select 
	br.branch_id, br.manager_id,
	Count(ist.issued_id) as total_book_issued, 
	count(rst.return_id) as Total_book_returned, 
	SUM(bk.rental_price) as total_revenue 
	from issued_status as ist

left Join return_status as rst
on rst.issued_id = ist.issued_id

 join books as bk
on bk.isbn = ist.issued_book_isbn

 join employees as e
on e.emp_id = ist.issued_emp_id
	
 join branch as br
on br.branch_id = e.branch_id

group by (br.branch_id, br.manager_id)

/*Find Employees with the Most Book Issues Processed
Write a query to find the top 3 employees who have processed the most book issues. 
Display the employee name, number of books processed, and their branch.*/
SELECT e.emp_name, br.branch_id, COUNT(ist.issued_id) as Total_book_issued FROM issued_status as ist
 join employees as e
on e.emp_id = ist.issued_emp_id
	
 join branch as br
on br.branch_id = e.branch_id
group by (e.emp_name, br.branch_id)
order by Total_book_issued desc
