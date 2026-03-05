--Database & Table Creation
--Note: Values were imported directly to the database after of table creation
CREATE DATABASE customer_churn;

CREATE TABLE customers (
    customer_id VARCHAR(10) PRIMARY KEY,
    gender VARCHAR(10),
    senior_citizen SMALLINT,
    partner VARCHAR(5),
    dependents VARCHAR(5),
    tenure SMALLINT,
    phone_service VARCHAR(5),
    multiple_lines VARCHAR(20),
    internet_service VARCHAR(20),
    online_security VARCHAR(20),
    online_backup VARCHAR(20),
    device_protection VARCHAR(20),
    tech_support VARCHAR(20),
    streaming_tv VARCHAR(20),
    streaming_movies VARCHAR(20),
    contract VARCHAR(20),
    paperless_billing VARCHAR(5),
    payment_method VARCHAR(30),
    monthly_charges DECIMAL(8,2),
    total_charges DECIMAL(10,2),
    churn VARCHAR(5)
);

--NULL value check
SELECT
  SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS null_customer_id,
  SUM(CASE WHEN gender IS NULL THEN 1 ELSE 0 END) AS null_gender,
  SUM(CASE WHEN senior_citizen IS NULL THEN 1 ELSE 0 END) AS null_senior_citizen,
  SUM(CASE WHEN partner IS NULL THEN 1 ELSE 0 END) AS null_partner,
  SUM(CASE WHEN dependents IS NULL THEN 1 ELSE 0 END) AS null_dependents,
  SUM(CASE WHEN tenure IS NULL THEN 1 ELSE 0 END) AS null_tenure,
  SUM(CASE WHEN phone_service IS NULL THEN 1 ELSE 0 END) AS null_phone_service,
  SUM(CASE WHEN multiple_lines IS NULL THEN 1 ELSE 0 END) AS null_multiple_lines,
  SUM(CASE WHEN internet_service IS NULL THEN 1 ELSE 0 END) AS null_internet_service,
  SUM(CASE WHEN online_security IS NULL THEN 1 ELSE 0 END) AS null_online_security,
  SUM(CASE WHEN online_backup IS NULL THEN 1 ELSE 0 END) AS null_online_backup,
  SUM(CASE WHEN device_protection IS NULL THEN 1 ELSE 0 END) AS null_device_protection,
  SUM(CASE WHEN tech_support IS NULL THEN 1 ELSE 0 END) AS null_tech_support,
  SUM(CASE WHEN streaming_tv IS NULL THEN 1 ELSE 0 END) AS null_streaming_tv,
  SUM(CASE WHEN streaming_movies IS NULL THEN 1 ELSE 0 END) AS null_streaming_movies,
  SUM(CASE WHEN contract IS NULL THEN 1 ELSE 0 END) AS null_contract,
  SUM(CASE WHEN paperless_billing IS NULL THEN 1 ELSE 0 END) AS null_paperless_billing,
  SUM(CASE WHEN payment_method IS NULL THEN 1 ELSE 0 END) AS null_payment_method,
  SUM(CASE WHEN monthly_charges IS NULL THEN 1 ELSE 0 END) AS null_monthly_charges,
  SUM(CASE WHEN total_charges IS NULL THEN 1 ELSE 0 END) AS null_total_charges,
  SUM(CASE WHEN churn IS NULL THEN 1 ELSE 0 END) AS null_churn
FROM customers;

--Replace null value for total charge to zero since their tenure is also zero
SELECT * FROM customers
WHERE total_charges IS NULL;

UPDATE customers
SET total_charges = 0
WHERE total_charges IS NULL;

--Remove unnecessary characters and capitalized each value
UPDATE customers
SET payment_method = REPLACE(INITCAP(payment_method),' (automatic)','');

UPDATE customers
SET internet_service = INITCAP(internet_service) 
WHERE internet_service = 'Fiber Optic';

--Duplicate data check
SELECT customer_id, COUNT(*)
FROM customers
GROUP BY customer_id
HAVING COUNT(*) > 1;

--Inconsistent data check (internet services)
SELECT customer_id, 
	   internet_service,
	   online_security, 
	   online_backup, 
	   device_protection, 
	   tech_support, 
	   streaming_tv, 
	   streaming_movies
FROM customers
WHERE internet_service = 'No'
AND (
    online_security != 'No internet service' OR
    online_backup != 'No internet service' OR
    device_protection != 'No internet service' OR
    tech_support != 'No internet service' OR
    streaming_tv != 'No internet service' OR
    streaming_movies != 'No internet service'
);

--Inconsistent data check (phone services)
SELECT customer_id, phone_service, multiple_lines
FROM customers
WHERE phone_service = 'No' AND multiple_lines != 'No phone service';

--Outlier detection for monthly charge
SELECT customer_id, monthly_charges
FROM customers
WHERE monthly_charges > (SELECT AVG(monthly_charges) + 3 * STDDEV(monthly_charges) FROM customers);

--Finding an invalid total charge by tenure
SELECT customer_id, tenure, total_charges
FROM customers
WHERE tenure > 0 AND total_charges = 0;

--Churn rate
SELECT COUNT(*) AS total_customers,
	   SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
	   ROUND(SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END)::NUMERIC / COUNT(*) * 100, 2) AS churn_rate
FROM customers;

-- Distribution of customers by gender and its churn rate
SELECT gender, 
	   COUNT(*) AS total_customers,
	   SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
	   ROUND(SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END)::NUMERIC / COUNT(*) * 100, 2) AS churn_rate
FROM customers
GROUP BY gender
ORDER BY total_customers DESC;

--Churn rate by customer's partner status
SELECT partner, 
	   COUNT(*) AS total_customers,
	   SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
	   ROUND(SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END)::NUMERIC / COUNT(*) * 100, 2) AS churn_rate
FROM customers
GROUP BY partner
ORDER BY total_customers DESC;

--Percentage of senior citizens and churn rate
SELECT 
  CASE WHEN senior_citizen = 1 THEN 'Yes' ELSE 'No' END AS senior_citizen,
  COUNT(*) AS total_customers,
  ROUND(COUNT(*)::NUMERIC / (SELECT COUNT(*) FROM customers) * 100,2) AS percentage,
  SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
  ROUND(SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END)::NUMERIC / COUNT(*) * 100, 2) AS churn_rate
FROM customers
GROUP BY senior_citizen
ORDER BY total_customers DESC;

--Customers dependents status and churn rate
SELECT dependents, 
	   COUNT(*) AS total_customers,
	   SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
	   ROUND(SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END)::NUMERIC / COUNT(*) * 100, 2) AS churn_rate
FROM customers
GROUP BY dependents
ORDER BY total_customers DESC;

--Churn rate by gender, senior status, and partner
SELECT gender,
       CASE WHEN senior_citizen = 1 THEN 'Yes' ELSE 'No' END AS senior_citizen,
       partner,
       COUNT(*) AS total_customers,
	   SUM(CASE WHEN churn='Yes' THEN 1 ELSE 0 END) churned_customers,
       ROUND(SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END)::NUMERIC / COUNT(*) * 100, 2) AS churn_rate
FROM customers
GROUP BY gender, senior_citizen, partner
ORDER BY total_customers DESC;

--Distribution of customers with/without phone service with churn rate
SELECT phone_service, 
	   COUNT(*) AS total_customers,
	   SUM(CASE WHEN churn='Yes' THEN 1 ELSE 0 END) churned_customers,
       ROUND(SUM(CASE WHEN churn='Yes' THEN 1 ELSE 0 END)::NUMERIC / COUNT(*) * 100, 2) AS churn_rate
FROM customers
GROUP BY phone_service
ORDER BY total_customers DESC;

--Distribution of customers with/without multiple lines with churn rate
SELECT multiple_lines, 
	   COUNT(*) AS total_customers,
	   SUM(CASE WHEN churn='Yes' THEN 1 ELSE 0 END) churned_customers,
       ROUND(SUM(CASE WHEN churn='Yes' THEN 1 ELSE 0 END)::NUMERIC / COUNT(*) * 100, 2) AS churn_rate
FROM customers
WHERE multiple_lines != 'No phone service'
GROUP BY multiple_lines
ORDER BY total_customers DESC;

--Distribution of internet services with churn rate
SELECT internet_service, 
	   COUNT(*) AS total_customers,
	   SUM(CASE WHEN churn='Yes' THEN 1 ELSE 0 END) churned_customers,
       ROUND(SUM(CASE WHEN churn='Yes' THEN 1 ELSE 0 END)::NUMERIC / COUNT(*) * 100, 2) AS churn_rate
FROM customers
GROUP BY internet_service
ORDER BY total_customers DESC;

--Combined tech & entertainment-related churn analysis
WITH service_data AS (
  SELECT 'Online Security' AS service, online_security AS status, churn FROM customers
  UNION ALL
  SELECT 'Online Backup', online_backup, churn FROM customers
  UNION ALL
  SELECT 'Device Protection', device_protection, churn FROM customers
  UNION ALL
  SELECT 'Tech Support', tech_support, churn FROM customers
  UNION ALL
  SELECT 'Streaming TV', streaming_tv, churn FROM customers
  UNION ALL
  SELECT 'Streaming Movies', streaming_movies, churn FROM customers
)
SELECT service, status,
       COUNT(*) AS total_customers,
	   SUM(CASE WHEN churn='Yes' THEN 1 ELSE 0 END) churned_customers,
       ROUND(SUM(CASE WHEN churn='Yes' THEN 1 ELSE 0 END)::NUMERIC / COUNT(*) * 100, 2) AS churn_rate
FROM service_data
WHERE status != 'No internet service'
GROUP BY service, status
ORDER BY total_customers DESC;

--Multi-service relationship
WITH multiple_service AS (
  SELECT customer_id, churn,
    (
      (CASE WHEN phone_service = 'Yes' THEN 1 ELSE 0 END) +
      (CASE WHEN multiple_lines = 'Yes' THEN 1 ELSE 0 END) +
      (CASE WHEN internet_service != 'No' THEN 1 ELSE 0 END) +
      (CASE WHEN online_security = 'Yes' THEN 1 ELSE 0 END) +
      (CASE WHEN online_backup = 'Yes' THEN 1 ELSE 0 END) +
      (CASE WHEN device_protection = 'Yes' THEN 1 ELSE 0 END) +
      (CASE WHEN tech_support = 'Yes' THEN 1 ELSE 0 END) +
      (CASE WHEN streaming_tv = 'Yes' THEN 1 ELSE 0 END) +
      (CASE WHEN streaming_movies = 'Yes' THEN 1 ELSE 0 END)
    ) AS num_service
  FROM customers
)
SELECT num_service,
       COUNT(*) AS total_customers,
	   SUM(CASE WHEN churn='Yes' THEN 1 ELSE 0 END) churned_customers,
       ROUND(SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END)::NUMERIC / COUNT(*) * 100, 2) AS churn_rate
FROM multiple_service
GROUP BY num_service
ORDER BY num_service ASC;

--Determine whether the number of services has a relationship with services that have high churn.
WITH multiple_service AS (
  SELECT customer_id, churn,
    (
      (CASE WHEN phone_service = 'Yes' THEN 1 ELSE 0 END) +
      (CASE WHEN multiple_lines = 'Yes' THEN 1 ELSE 0 END) +
      (CASE WHEN internet_service != 'No' THEN 1 ELSE 0 END) +
      (CASE WHEN online_security = 'Yes' THEN 1 ELSE 0 END) +
      (CASE WHEN online_backup = 'Yes' THEN 1 ELSE 0 END) +
      (CASE WHEN device_protection = 'Yes' THEN 1 ELSE 0 END) +
      (CASE WHEN tech_support = 'Yes' THEN 1 ELSE 0 END) +
      (CASE WHEN streaming_tv = 'Yes' THEN 1 ELSE 0 END) +
      (CASE WHEN streaming_movies = 'Yes' THEN 1 ELSE 0 END)
    ) AS num_service
  FROM customers
),
less_service AS (
	SELECT customer_id
	FROM customers 
	WHERE online_security = 'No' OR online_backup = 'No' OR tech_support = 'No' OR device_protection = 'No'
)
SELECT num_service,
       COUNT(*) AS total_customers,
	   SUM(CASE WHEN churn='Yes' THEN 1 ELSE 0 END) churned_customers,
       ROUND(SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END)::NUMERIC / COUNT(*) * 100, 2) AS churn_rate
FROM multiple_service AS ms
INNER JOIN less_service AS ls ON ms.customer_id = ls.customer_id
GROUP BY num_service
ORDER BY num_service ASC;

--Tenure range
SELECT MIN(tenure) AS min_tenure, MAX(tenure) AS max_tenure
FROM customers;

--Tenure distribution for churned vs.loyal customers
SELECT CASE 
		 WHEN tenure BETWEEN 0 AND 12 THEN 'Less than one year'
		 WHEN tenure BETWEEN 13 AND 24 THEN '1-2 years'
		 WHEN tenure BETWEEN 25 AND 36 THEN '2-3 years'
		 WHEN tenure BETWEEN 37 AND 48 THEN '3-4 years'
		 WHEN tenure BETWEEN 49 AND 60 THEN '4-5 years'
		 WHEN tenure BETWEEN 61 AND 72 THEN 'More than five years'
	   END AS tenure_range,
	   COUNT(*) AS total_customers,
	   SUM(CASE WHEN churn='Yes' THEN 1 ELSE 0 END) churned_customers,
	   ROUND(SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END)::NUMERIC / COUNT(*) * 100, 2) AS churn_rate
FROM customers
GROUP BY tenure_range
ORDER BY churn_rate DESC;

--Churn rate by contract type
SELECT contract,
       COUNT(*) AS total_customers,
	   SUM(CASE WHEN churn='Yes' THEN 1 ELSE 0 END) churned_customers,
       ROUND(SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END)::NUMERIC / COUNT(*) * 100, 2) AS churn_rate
FROM customers
GROUP BY contract
ORDER BY total_customers DESC;

--Churn rate by payment method
SELECT payment_method,
       COUNT(*) AS total_customers,
	   SUM(CASE WHEN churn='Yes' THEN 1 ELSE 0 END) churned_customers,
       ROUND(SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END)::NUMERIC / COUNT(*) * 100, 2) AS churn_rate
FROM customers
GROUP BY payment_method
ORDER BY total_customers DESC;

--Churn rate by contract type and payment method
SELECT contract, 
	   payment_method,
       COUNT(*) AS total_customers,
       SUM(CASE WHEN churn='Yes' THEN 1 ELSE 0 END) AS churned_customers,
       ROUND(SUM(CASE WHEN churn='Yes' THEN 1 ELSE 0 END)::NUMERIC / COUNT(*) * 100, 2) AS churn_rate
FROM customers
GROUP BY contract, payment_method
ORDER BY total_customers DESC;

--Churn rate by contract type and internet service
SELECT contract, 
	   internet_service,
	   COUNT(*) AS total_customers,
	   SUM(CASE WHEN churn='Yes' THEN 1 ELSE 0 END) AS churned_customers,
       ROUND(AVG(CASE WHEN churn='Yes' THEN 1 ELSE 0 END)*100,2) AS churn_rate
FROM customers
WHERE internet_service != 'No'
GROUP BY contract, internet_service
ORDER BY total_customers DESC;

--Churn rate by contract type and phone service
SELECT contract, 
	   phone_service,
	   COUNT(*) AS total_customers,
	   SUM(CASE WHEN churn='Yes' THEN 1 ELSE 0 END) AS churned_customers,
       ROUND(AVG(CASE WHEN churn='Yes' THEN 1 ELSE 0 END)*100,2) AS churn_rate
FROM customers
GROUP BY contract, phone_service
ORDER BY total_customers DESC;

--Effect of paperless billing
SELECT paperless_billing,
       COUNT(*) AS total_customers,
	   SUM(CASE WHEN churn='Yes' THEN 1 ELSE 0 END) churned_customers,
       ROUND(SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END)::NUMERIC / COUNT(*) * 100, 2) AS churn_rate
FROM customers
GROUP BY paperless_billing
ORDER BY churn_rate DESC;

--Effect of paperless billing along with payment method
SELECT paperless_billing, 
	   payment_method,
       COUNT(*) AS total_customers,
	   SUM(CASE WHEN churn='Yes' THEN 1 ELSE 0 END) churned_customers,
       ROUND(SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END)::NUMERIC / COUNT(*) * 100, 2) AS churn_rate
FROM customers
GROUP BY paperless_billing,payment_method
ORDER BY churn_rate DESC;

--Average charges per contract type
SELECT contract,
       ROUND(AVG(monthly_charges), 2) AS avg_monthly_charge,
       ROUND(AVG(total_charges), 2) AS avg_total_charge
FROM customers
GROUP BY contract
ORDER BY avg_monthly_charge DESC;

--Average charges per payment method type
SELECT payment_method,
       ROUND(AVG(monthly_charges), 2) AS avg_monthly_charge,
       ROUND(AVG(total_charges), 2) AS avg_total_charge
FROM customers
GROUP BY payment_method
ORDER BY avg_monthly_charge DESC;

--Revenue impact of churn
SELECT SUM(total_charges) AS total_revenue,
	   SUM(total_charges) FILTER (WHERE churn='No') AS retained_revenue,
       SUM(total_charges) FILTER (WHERE churn='Yes') AS churned_revenue,
       ROUND(SUM(total_charges) FILTER (WHERE churn='Yes') / SUM(total_charges) * 100, 2) AS revenue_loss_pct
FROM customers;