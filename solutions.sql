-- techTFQ
-- Subquery in SQL | Correlated Subquery + Complete SQL Subqueries Tutorial
-- video link: https://www.youtube.com/watch?v=nJIEIzF7tDw

-- Types of Subqueries:
-- 1. Scalar Subquery				: Subquery which will always return only 1 row & 1 column
-- 2. Multiple Row Subquery			: Subquery which returns multiple rows. Two Types: 1. Multiple rows & columns, 2. Multiple Rows but only 1 column
-- 3. Correlated Subquery

-- We can use a subquery in:
-- 1. select caluse					: not common & unrecommended. Can instead put subquery in join/from. Is for aggregate solutions.
-- 2. where clause
-- 3. from clause (and join) 		: when we use a subquery in a from /join clause, that subquery is returned as a seperate table
-- Having
-- INSERT
-- UPDATE
-- DELETE

-- To compare more than one column in a filter condition, where (col1, col2) in ()
-- first the subquery is run
----------------------------
-- **Q1**
-- q1. find the employees who's salary is more than the average salary earned by all employees

-- solution 1
select * from employee
where salary > (select avg(salary) from employee)

-- In this solution a scalar subquery was used
-- Scalar Subquery

-- solution 2
select * from employee as e1
join (select avg(salary) as avgs from employee) as avg_sal
on e1.salary > avg_sal.avgs

----------------------------
-- **Q2**
-- q2. Find Employees who earned the highest salary in each department

select dept_name, salary from employee
where (dept_name, salary) in (select dept_name, max(salary) from employee
								group by dept_name)
								
----------------------------
-- **Q3**
-- q3. Find department(s) who do not have any employees.

-- Department table has list of all departments

-- solution without subquery

select dept_name, count(emp_name) from department
left join employee
using(dept_name)
group by dept_name
having count(emp_name) = 0;

-- solution with subquery

select * from department
where dept_name not in (select distinct(dept_name) from employee)

-- this inside subquery is of single col & multiple rows type. Used for comparing
----------------------------
-- **CORRELATED SUBQUERY**

-- It is a subquery which is related to the outer query
-- Processing of the subquery depends on the values that are returned from the outer query
-- In other words we refer something in a subquery that is present in the outer query
-- Scalar & Multiple row subqueries are independant of the outer query. Also, in these 2, the subquery is runned only once & run first - b/c the data is available
-- But in Correlated Subquery, 
----------------------------
-- **Q4**
-- q4. Find the employees in each department  who earn more than the average salary in that department


select * from employee as e1
where  salary > (select avg(salary) from employee as e2
				where e1.dept_name = e2.dept_name)
				
-- here e1 in the subquery is executed 24 times
----------------------------
-- **Q5**
-- q5. Find department(s) who do not have any employees, using correlated subquery

-- The Exists keyword evaluates true or false, but the IN keyword will compare all values in the corresponding subuery column

select * from department as d
where not exists (select dept_name from employee as e
						   where d.dept_name = e.dept_name)
						   
						   -- when subquery would return noting, not extists would be true, hence main query would return value for tat case

-- OLD SOLUTION
-- select * from department
-- where dept_name not in (select distinct(dept_name) from employee)

----------------------------
-- **NESTED SUBQUERY**

-- 
----------------------------
-- **Q6**
-- q6. Find stores whos sales were better than the average sales across all stores

-- STEPS:
-- 1. FIND TOTAL SALES FOR EACH STORE
-- 2. FIND AVG SALES FOR ALL THE STORES
-- 3. COMPARE 1 & 2

select * from
	(
select  store_name, sum(price) as total_sales 
	  from sales
	group by store_name
	) as total_sales_by_store
join 
	(
select avg(total_sales) as average
from (select  store_name, sum(price) as total_sales 
	  from sales 
	group by store_name) as avg_sales_by_all_stores
	) as avg_sales_by_all_stores
on total_sales_by_store.total_sales > avg_sales_by_all_stores.average
-- subquery in from must have an alias

----------------------------
-- **WITH CLAUSE**

-- WITH clause allows us to give a subquery block a name 
-- that can be used in multiple places within the main SELECT, INSERT, DELETE or UPDATE SQL query.

-- If a query is repeated multiple times we must use with
----------------------------
-- **Q6**
-- q6. Find stores whos sales were better than the average sales across all stores.
-- solving this by with

with a1 as (select  store_name, sum(price) as total_sales 
	  from sales
	group by store_name)
select * from
	a1 as total_sales_by_store
join 
	(
select avg(total_sales) as average
from a1 as avg_sales_by_all_stores
	) as avg_sales_by_all_stores
on total_sales_by_store.total_sales > avg_sales_by_all_stores.average

----------------------------
-- **Q7**
-- (SUBQUERY IN SELECT CLAUSE)
-- q7. Fetch all employee details and add remarks  to those employees who earn more than the average salary

select *, (case when salary > (select avg(salary) from employee) then 'Higher than average'
		  		else null end) as remarks
from employee
				
----------------------------
-- **Q8**
-- (SUBQUERY IN HAVING CLAUSE)
-- q8. Find the stores who have sold more units than the average units sold  by all stores.

select store_name, sum(quantity) from sales
group by store_name
having sum(quantity) > (select avg(quantity) from sales)

----------------------------
-- **Q9**
-- (SUBQUERY IN INSERT CLAUSE)
-- q9. Insert Data into employee history table. Make sure not to insert duplicate records.

-- select * from employee_history
-- currently employee history table is blank
-- This data is already available in employee and department table

insert into employee_history
select e.emp_id, e.emp_name, e.dept_name, e.salary, d.location
from employee as e
inner join department as d
on d.dept_name = e.dept_name
-- if employee information is already present in employee_history table, then we shoul'nt be entering it. for this we write
where not exists (select 1 
				  from employee_history as eh
				 where eh.emp_id = e.emp_id)
-- this where statement above is only going to insert those records which are not existing in the employee hostory table
-- if employee is present in hostory table then the eh subquery is going to return something, and where not exists would be false
-- if i run again 0 records would be inserted


----------------------------
-- **Q10**
-- (SUBQUERY IN UPDATE CLAUSE)
-- q10. Give 10% increment to all employees in Bangalore location based on the maximum salary earned by an employee in each department.
-- Only consider employees in the employee history table.


-- first i'll find maximum salary in each dept, and then give 10% of that to those employees who are working in bangalore location
-- The SET command is used with UPDATE to specify which columns and values that should be updated in a table.

update employee as e
set salary = (select max(salary) +(0.1*max(salary))
			 from employee_history as eh
			 where eh.dept_name = e.dept_name)
where e.dept_name in (select dept_name 
					  from department where location = 'Bangalore')
and e.emp_id in (select emp_id from employee_history)

----------------------------
-- **Q11**
-- (SUBQUERY IN DELETE CLAUSE)
-- q11. Delete all departments who do not have any employees

delete from department 
where dept_name in (select dept_name 
					from department as d
					where not exists (select 1 from employee as e
										where d.dept_name = e.dept_name)
				   )
