/* 

Data Cleaning


*/

-- Profiling Data

SELECT
	COUNT(*) AS total_rows,
	SUM(CASE WHEN hotel IS NULL THEN 1
		ELSE 0
		END) AS null_hotel,
	SUM(CASE WHEN country IS NULL THEN 1
		ELSE 0
		END) AS null_country,
	SUM(CASE WHEN adr < 0 THEN 1
		ELSE 0
		END) AS negative_adr
FROM PortfolioProject..hotel_booking

-- Checking Categorical fields
SELECT DISTINCT(hotel)
FROM PortfolioProject..hotel_booking

SELECT DISTINCT(customer_type)
FROM PortfolioProject..hotel_booking

-- Fixing Column Naming issues

EXEC sp_rename
'PortfolioProject..hotel_booking.[phone-number]',
'phone_number',
'COLUMN';

-- Fixing the Arrival date to reflect year-month-day

SELECT
	arrival_date_year,
	arrival_date_month,
	arrival_date_day_of_month
FROM PortfolioProject..hotel_booking

SELECT
	DATEFROMPARTS(
		arrival_date_year, 
		MONTH(CONVERT(date, arrival_date_month + '1 2000')), 
		arrival_date_day_of_month) AS arrival_date
FROM PortfolioProject..hotel_booking


SELECT *
FROM PortfolioProject..hotel_booking

--Removing timezone out of reservation_status_date
SELECT
	CONVERT(date,reservation_status_date) AS reservation_status_date
FROM PortfolioProject..hotel_booking

-- Converting all the NULL values in the Children Column to 0
SELECT
	COALESCE(children, 0) AS children_clean
FROM PortfolioProject..hotel_booking

-- Cleaned Analytics View

DROP VIEW IF EXISTS hotel_booking_clean --Run this query first if we plan on adding any edits to our View query
CREATE VIEW hotel_booking_clean AS
SELECT 
	hotel,
	is_canceled,
	lead_time,
	DATEFROMPARTS(
		arrival_date_year, 
		MONTH(CONVERT(date, arrival_date_month + '1 2000')), 
		arrival_date_day_of_month) AS arrival_date,
	stays_in_weekend_nights,
	stays_in_week_nights,
	adults,
	COALESCE(children, 0) AS children,
	babies,
	meal,
	country,
	market_segment,
	distribution_channel,
	is_repeated_guest,
	previous_cancellations,
	previous_bookings_not_canceled,
	reserved_room_type,
	assigned_room_type,
	booking_changes,
	deposit_type,
	days_in_waiting_list,
	customer_type,
	--ADR cannot be negative
	CASE
		WHEN adr < 0 THEN NULL
		ELSE adr
	END AS adr,
	required_car_parking_spaces,
	total_of_special_requests,
	reservation_status,
	CONVERT(date,reservation_status_date) AS reservation_status_date,
	name,
	email,
	phone_number,
	credit_card
FROM PortfolioProject..hotel_booking


-- Business Metrics

SELECT 
	*,
	(stays_in_week_nights + stays_in_weekend_nights) AS total_nights,
	adr * (stays_in_week_nights + stays_in_weekend_nights) AS total_revenue
FROM hotel_booking_clean

SELECT 
	reservation_status,
	COUNT(*) AS guests
FROM hotel_booking_clean
GROUP BY reservation_status

-- Final Analytics View

CREATE VIEW hotel_analytics AS
SELECT 
	hotel,
	arrival_date,
	DATENAME(WEEKDAY, arrival_date) AS arrival_day,
	customer_type,
	market_segment,
	is_canceled,
	total_nights,
	total_revenue
FROM (
	SELECT *,
		(stays_in_week_nights + stays_in_weekend_nights) AS total_nights,
		ADR*(stays_in_week_nights + stays_in_weekend_nights) AS total_revenue
	FROM hotel_booking_clean) AS total;

SELECT *
FROM hotel_analytics
