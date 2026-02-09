Запити

1. Покажіть середню зарплату співробітників за кожен рік, до 2005 року.

SELECT ROUND(AVG(salary),2) AS average_salary, YEAR(from_date) FROM salaries
WHERE YEAR(from_date)<2005
GROUP BY YEAR(from_date)
ORDER BY YEAR(from_date);

2. Покажіть середню зарплату співробітників по кожному відділу. Примітка: потрібно розрахувати по поточній зарплаті, та поточному відділу співробітників.

SELECT ROUND(AVG(salaries.salary),2) AS average_salary, dept_emp.dept_no FROM salaries
JOIN dept_emp ON dept_emp.emp_no=salaries.emp_no 
WHERE dept_emp.to_date>CURDATE() AND salaries.to_date>CURDATE() 
GROUP BY dept_emp.dept_no
ORDER BY dept_emp.dept_no;

3. Покажіть середню зарплату співробітників по кожному відділу за кожний рік.

SELECT ROUND(AVG(salaries.salary),2) AS average_salary, YEAR(salaries.from_date) AS year_sal, dept_emp.dept_no FROM salaries
JOIN dept_emp ON dept_emp.emp_no=salaries.emp_no 
GROUP BY dept_emp.dept_no, year_sal
ORDER BY dept_emp.dept_no, year_sal;

4. Покажіть відділи в яких зараз працює більше 15000 співробітників.

SELECT dept_no, COUNT(emp_no) AS count_emp FROM dept_emp
WHERE to_date>CURDATE()  
GROUP BY dept_no
HAVING COUNT(emp_no)>15000;

5. Для менеджера який працює найдовше покажіть його номер, відділ, дату прийому на роботу, прізвище.

SELECT employees.emp_no, dept_manager.dept_no, employees.hire_date, employees.last_name FROM employees
JOIN dept_manager ON dept_manager.emp_no=employees.emp_no
WHERE dept_manager.to_date>CURDATE()  
AND employees.hire_date = (SELECT MIN(e.hire_date) FROM employees AS e
                           JOIN dept_manager AS  d ON d.emp_no=e.emp_no
                           WHERE d.to_date>CURDATE());

6. Покажіть топ-10 діючих співробітників компанії з найбільшою різницею між їх зарплатою і середньою зарплатою в їх відділі.

WITH avg_sal_dept AS  (SELECT ROUND(AVG(salaries.salary),2) AS average_salary, dept_emp.dept_no FROM salaries
                       JOIN dept_emp ON dept_emp.emp_no=salaries.emp_no 
                       WHERE dept_emp.to_date>CURDATE() AND salaries.to_date>CURDATE() 
                       GROUP BY dept_emp.dept_no)
SELECT salaries.emp_no, salaries.salary, (salaries.salary-avg_sal_dept.average_salary) AS diff_salary, dept_emp.dept_no FROM salaries
JOIN dept_emp ON dept_emp.emp_no=salaries.emp_no  
JOIN avg_sal_dept ON avg_sal_dept.dept_no=dept_emp.dept_no
WHERE salaries.to_date>CURDATE() AND dept_emp.to_date>CURDATE()
ORDER BY diff_salary DESC
LIMIT 10;

7. Для кожного відділу покажіть другого по порядку менеджера. Необхідно вивести відділ, прізвище ім’я менеджера, дату прийому на роботу менеджера і дату коли він став менеджером відділу

SELECT num.dept_no, CONCAT(employees.last_name, ' ', employees.first_name) AS name_manager, employees.hire_date, num.from_date FROM
(SELECT emp_no, dept_no, from_date,
ROW_NUMBER() over ( partition by dept_no order by emp_no) as num_manager
FROM dept_manager) AS num
JOIN employees ON employees.emp_no=num.emp_no
WHERE num.num_manager = 2;
