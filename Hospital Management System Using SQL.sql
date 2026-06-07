create database hospital;
use hospital;

show tables;

select * from appointments;

select * from billing;

select * from treatments;

select * from patients;

select * from doctors;


-- Q1.Show the latest appointment date for each patient.
SELECT patient_id,
       MAX(appointment_date) AS latest_appointment
FROM appointments
GROUP BY patient_id;



-- Q2.Find doctors with maximum experience.
SELECT *
FROM doctors
WHERE years_experience =
(
    SELECT MAX(years_experience)
    FROM doctors
);



-- Q3.Which treatment generated the highest revenue?
SELECT
    treatment_type,
    SUM(cost) AS revenue
FROM treatments
GROUP BY treatment_type
ORDER BY revenue DESC
LIMIT 1;



-- Q4.find the total billing amount,average billing amount, and number of bills per payment method.
SELECT payment_method,
       COUNT(*)   AS num_bills,
       ROUND(SUM(amount), 2)  AS total_amount,
       ROUND(AVG(amount), 2)  AS avg_amount
FROM   billing
GROUP BY payment_method
ORDER BY total_amount DESC;



-- Q5.show the full name of each patient along with their appointment date and reason for visit
SELECT p.first_name,
       p.last_name,
       a.appointment_date,
       a.reason_for_visit,
       a.status
FROM   patients     p
INNER JOIN appointments a
       ON p.patient_id = a.patient_id
ORDER BY a.appointment_date;



-- Q6.show all doctors and how many appointments each has handled including doctors with zero appointments
SELECT d.first_name,
       d.last_name,
       d.specialization,
       COUNT(a.appointment_id) AS total_appointments
FROM   doctors       d
LEFT JOIN appointments a
       ON d.doctor_id = a.doctor_id
GROUP BY d.doctor_id, d.first_name, d.last_name, d.specialization
ORDER BY total_appointments DESC;



-- Q7.Show all patients and their billing details, including patients who have not been billed.
SELECT p.patient_id,
       p.first_name,
       p.last_name,
       b.bill_id,
       b.amount
FROM billing b
RIGHT JOIN patients p
ON b.patient_id = p.patient_id;



-- Q8.Show the top 5 most expensive treatments.
SELECT
  treatment_id,
  treatment_type,
  description,
  cost
FROM treatments
ORDER BY cost DESC
LIMIT 5;



-- Q9.Show doctors ranked 3rd to 5th by years of experience (skip the top 2).
SELECT
  doctor_id,
  CONCAT(first_name, ' ', last_name) AS doctor_name,
  specialization,
  years_experience
FROM doctors
ORDER BY years_experience DESC
LIMIT 3 OFFSET 2;



-- Q10.Find how many appointments were booked in each month by name (January, February, etc.)
SELECT
  MONTHNAME(appointment_date) AS month_name,
  MONTH(appointment_date)     AS month_number,
  COUNT(*)                    AS total_appointments
FROM appointments
GROUP BY MONTH(appointment_date), MONTHNAME(appointment_date)
ORDER BY month_number;



-- Q11.Find appointments scheduled on weekends
SELECT
    appointment_id,
    patient_id,
    appointment_date,
    DAYNAME(appointment_date) AS day_name
FROM appointments
WHERE DAYOFWEEK(appointment_date) IN (1,7);



-- Q12.Show the month and year of each appointment
SELECT
    appointment_id,
    DATE_FORMAT(appointment_date,'%M %Y') AS appointment_month
FROM appointments;



-- Q13.Categorize each bill based on its payment status for reporting purposes.
SELECT
    bill_id,
    patient_id,
    amount,
    payment_method,
    payment_status,
    CASE
        WHEN payment_status = 'Paid' THEN 'Completed'
        WHEN payment_status = 'Pending' THEN 'Awaiting Payment'
        ELSE 'Requires Review'
    END AS status_label
FROM billing
ORDER BY bill_date DESC;



-- Q14.Assign a serial number to each appointment per doctor, ordered by appointment date
SELECT
  doctor_id,
  appointment_id,
  patient_id,
  appointment_date,
  status,
  ROW_NUMBER() OVER (
    PARTITION BY doctor_id
    ORDER BY appointment_date
  ) AS appointment_number
FROM appointments
ORDER BY doctor_id, appointment_date;



-- Q15.Rank all patients by their total amount billed — patient with highest total gets rank 1
SELECT
  patient_id,
  SUM(amount)                              AS total_billed,
  RANK() OVER (ORDER BY SUM(amount) DESC)  AS billing_rank
FROM billing
GROUP BY patient_id
ORDER BY billing_rank;



-- Q16.Rank treatment types by total revenue without skipping ranks
SELECT
    treatment_type,
    SUM(cost) AS total_revenue,
    DENSE_RANK() OVER (
        ORDER BY SUM(cost) DESC
    ) AS revenue_rank
FROM treatments
GROUP BY treatment_type;



-- Q17.Using a CTE, find all patients who have more than 3 appointments — show their name and appointment count.
WITH patient_appointment_count AS (
  -- Step 1: count appointments per patient
  SELECT
    patient_id,
    COUNT(*) AS total_appointments
  FROM appointments
  GROUP BY patient_id
)
-- Step 2: join with patients table and filter
SELECT
  p.patient_id,
  CONCAT(p.first_name, ' ', p.last_name) AS full_name,
  p.gender,
  pac.total_appointments
FROM patients p
JOIN patient_appointment_count pac
  ON p.patient_id = pac.patient_id
WHERE pac.total_appointments > 3
ORDER BY pac.total_appointments DESC;



-- Q18.Find patients whose total billing amount is higher than the average total billing amount of all patients.
SELECT
    patient_id,
    SUM(amount) AS total_bill
FROM billing
GROUP BY patient_id
HAVING SUM(amount) >
(
    SELECT AVG(patient_total)
    FROM
    (
        SELECT SUM(amount) AS patient_total
        FROM billing
        GROUP BY patient_id
    ) avg_bill
);



-- Q19.Categorize doctors based on years of experience.
SELECT
    doctor_id,
    CONCAT(first_name,' ',last_name) AS doctor_name,
    years_experience,
    CASE
        WHEN years_experience < 5 THEN 'Junior'
        WHEN years_experience BETWEEN 5 AND 10 THEN 'Mid-Level'
        ELSE 'Senior'
    END AS experience_level
FROM doctors;



-- Q20.Find doctors who handled more appointments than the average number of appointments handled by all doctors.
WITH doctor_appointments AS
(
    SELECT
        doctor_id,
        COUNT(*) AS total_appointments
    FROM appointments
    GROUP BY doctor_id
)
SELECT *
FROM doctor_appointments
WHERE total_appointments >
(
    SELECT AVG(total_appointments)
    FROM doctor_appointments
);






