CREATE DATABASE bank_loan_db;
USE bank_loan_db;
CREATE TABLE bank_loan_data (
    id INT,
    address_state VARCHAR(10),
    application_type VARCHAR(50),
    emp_length VARCHAR(30),
    emp_title VARCHAR(255),
    grade VARCHAR(5),
    home_ownership VARCHAR(30),
    issue_date DATE,
    last_credit_pull_date DATE,
    last_payment_date DATE,
    loan_status VARCHAR(50),
    next_payment_date DATE,
    member_id INT,
    purpose VARCHAR(100),
    sub_grade VARCHAR(10),
    term VARCHAR(30),
    verification_status VARCHAR(50),
    annual_income DOUBLE,
    dti DOUBLE,
    installment DOUBLE,
    int_rate DOUBLE,
    loan_amount DOUBLE,
    total_acc INT,
    total_payment DOUBLE
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/financial_loan.csv'
INTO TABLE bank_loan_data
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(
id,
address_state,
application_type,
emp_length,
emp_title,
grade,
home_ownership,
@issue_date,
@last_credit_pull_date,
@last_payment_date,
loan_status,
@next_payment_date,
member_id,
purpose,
sub_grade,
term,
verification_status,
annual_income,
dti,
installment,
int_rate,
loan_amount,
total_acc,
total_payment
)
SET
issue_date = STR_TO_DATE(@issue_date,'%d-%m-%Y'),
last_credit_pull_date = STR_TO_DATE(@last_credit_pull_date,'%d-%m-%Y'),
last_payment_date = STR_TO_DATE(@last_payment_date,'%d-%m-%Y'),
next_payment_date =
CASE
    WHEN @next_payment_date = ''
         OR @next_payment_date IS NULL
         OR @next_payment_date = '0000-00-00'
    THEN NULL
    ELSE STR_TO_DATE(@next_payment_date,'%d-%m-%Y')
END;


SELECT * FROM bank_loan_data;

-- Total Loan Applications
SELECT COUNT(id) AS Total_Loan_Applications FROM bank_loan_data;
-- MTD Loan Applications
SELECT COUNT(id) AS MTD_Total_Loan_Applications FROM bank_loan_data
WHERE MONTH(issue_date) = 12 AND YEAR(issue_date)=2021;
-- PMTD Loan Applications
SELECT COUNT(id) AS PMTD_Total_Loan_Applications FROM bank_loan_data
WHERE MONTH(issue_date) = 11 AND YEAR(issue_date)=2021;


-- Total Funded Amount
SELECT SUM(loan_amount) AS Total_Funded_Amount FROM bank_loan_data;
-- MTD Total Funded Amount
SELECT SUM(loan_amount) AS MTD_Total_Funded_Amount FROM bank_loan_data
WHERE MONTH(issue_date) = 12 AND YEAR(issue_date)=2021;
-- PMTD Total Funded Amount
SELECT SUM(loan_amount) AS PMTD_Total_Funded_Amount FROM bank_loan_data
WHERE MONTH(issue_date) = 11 AND YEAR(issue_date)=2021;


-- Total Amount Received
SELECT SUM(total_payment) AS Total_Amount_Received FROM bank_loan_data;
-- MTD Total Amount Received
SELECT SUM(total_payment) AS MTD_Total_Amount_Received FROM bank_loan_data
WHERE MONTH(issue_date) = 12 AND YEAR(issue_date)=2021;
-- PMTD Total Amount Received
SELECT SUM(total_payment) AS PMTD_Total_Amount_Received FROM bank_loan_data
WHERE MONTH(issue_date) = 11 AND YEAR(issue_date)=2021;


-- Average Interest Rate
SELECT ROUND(AVG(int_rate)*100,2) AS Avg_Interest_Rate FROM bank_loan_data;
-- MTD Average Interest
SELECT ROUND(AVG(int_rate)*100,2) AS MTD_Avg_Interest_Rate FROM bank_loan_data
WHERE MONTH(issue_date) = 12 AND YEAR(issue_date)=2021;
-- PMTD Average Interest
SELECT ROUND(AVG(int_rate)*100,2) AS PMTD_Avg_Interest_Rate FROM bank_loan_data
WHERE MONTH(issue_date) = 11 AND YEAR(issue_date)=2021;


-- Avg DTI
SELECT ROUND(AVG(dti)*100,2) AS Avg_DTI FROM bank_loan_data;
-- MTD Avg DTI
SELECT ROUND(AVG(dti)*100,2) AS MTD_Avg_DTI FROM bank_loan_data
WHERE MONTH(issue_date) = 12 AND YEAR(issue_date)=2021;
-- PMTD Avg DTI
SELECT ROUND(AVG(dti)*100,2) AS PMTD_Avg_DTI FROM bank_loan_data
WHERE MONTH(issue_date) = 11 AND YEAR(issue_date)=2021;

-- GOOD LOAN ISSUED
-- Good Loan Percentage
SELECT ROUND(COUNT(loan_status)*100/(SELECT COUNT(*) FROM bank_loan_data)) AS Good_Loan_Percentage
FROM bank_loan_data
WHERE loan_status="Fully Paid" OR  loan_status="Current";
-- Good Loan Applications
SELECT COUNT(id) AS Good_Loan_Applications FROM bank_loan_data
WHERE loan_status = 'Fully Paid' OR loan_status = 'Current';
-- Good Loan Funded Amount
SELECT SUM(loan_amount) AS Good_Loan_Funded_amount FROM bank_loan_data
WHERE loan_status = 'Fully Paid' OR loan_status = 'Current';
-- Good Loan Amount Received
SELECT SUM(total_payment) AS Good_Loan_amount_received FROM bank_loan_data
WHERE loan_status = 'Fully Paid' OR loan_status = 'Current';



-- BAD LOAN ISSUED
-- Good Loan Amount Received
SELECT ROUND(COUNT(loan_status)*100/(SELECT COUNT(*) FROM bank_loan_data)) AS Bad_Loan_Percentage
FROM bank_loan_data
WHERE loan_status="Charged Off";
-- Bad Loan Applications
SELECT COUNT(id) AS Bad_Loan_Applications FROM bank_loan_data
WHERE loan_status = 'Charged Off';
-- Bad Loan Funded Amount
SELECT SUM(loan_amount) AS Bad_Loan_Funded_amount FROM bank_loan_data
WHERE loan_status = 'Charged Off';
-- Bad Loan Amount Received
SELECT SUM(total_payment) AS Bad_Loan_amount_received FROM bank_loan_data
WHERE loan_status = 'Charged Off';



-- LOAN STATUS
SELECT
        loan_status,
        COUNT(id) AS Total_Loan_Applications,
        SUM(total_payment) AS Total_Amount_Received,
        SUM(loan_amount) AS Total_Funded_Amount,
        AVG(int_rate * 100) AS Interest_Rate,
        AVG(dti * 100) AS DTI
    FROM bank_loan_data
    GROUP BY loan_status;
    
-- MTD Loan Status
SELECT 
	loan_status, 
	SUM(total_payment) AS MTD_Total_Amount_Received, 
	SUM(loan_amount) AS MTD_Total_Funded_Amount 
FROM bank_loan_data
WHERE MONTH(issue_date) = 12 AND YEAR(issue_date)=2021
GROUP BY loan_status;

-- MONTH
SELECT 
    MONTH(issue_date) AS Month_Number,
    MONTHNAME(issue_date) AS Month_Name,
    COUNT(id) AS Total_Loan_Applications,
    SUM(loan_amount) AS Total_Funded_Amount,
    SUM(total_payment) AS Total_Amount_Received
FROM bank_loan_data
GROUP BY MONTH(issue_date), MONTHNAME(issue_date)
ORDER BY MONTH(issue_date);

-- STATE
SELECT 
    address_state AS State,
    COUNT(id) AS Total_Loan_Applications,
    SUM(loan_amount) AS Total_Funded_Amount,
    SUM(total_payment) AS Total_Amount_Received
FROM bank_loan_data
GROUP BY address_state
ORDER BY COUNT(id) DESC;

-- TERM
SELECT 
	term AS Term, 
	COUNT(id) AS Total_Loan_Applications,
	SUM(loan_amount) AS Total_Funded_Amount,
	SUM(total_payment) AS Total_Amount_Received
FROM bank_loan_data
GROUP BY term
ORDER BY term;

-- EMPLOYEE LENGTH
SELECT 
	emp_length AS Employee_Length, 
	COUNT(id) AS Total_Loan_Applications,
	SUM(loan_amount) AS Total_Funded_Amount,
	SUM(total_payment) AS Total_Amount_Received
FROM bank_loan_data
GROUP BY emp_length
ORDER BY emp_length;

-- PURPOSE
SELECT 
	purpose AS PURPOSE, 
	COUNT(id) AS Total_Loan_Applications,
	SUM(loan_amount) AS Total_Funded_Amount,
	SUM(total_payment) AS Total_Amount_Received
FROM bank_loan_data
GROUP BY purpose
ORDER BY purpose;

-- HOME OWNERSHIP
SELECT 
	home_ownership AS Home_Ownership, 
	COUNT(id) AS Total_Loan_Applications,
	SUM(loan_amount) AS Total_Funded_Amount,
	SUM(total_payment) AS Total_Amount_Received
FROM bank_loan_data
GROUP BY home_ownership
ORDER BY home_ownership;

