Hotel Booking Data Cleaning & Analytics (T-SQL)

🔹 Project Overview

This project demonstrates how to clean, standardize, and prepare raw hotel booking data for analytics using T-SQL, following real-world data engineering and analytics best practices.

The focus is on:

Preserving raw data

Applying business logic

Creating reusable, analytics-ready SQL views

This project is designed to reflect how SQL is used in production environments, not just academic exercises.

🔹 Dataset

Source: Hotel booking Excel dataset by Mojtaba on Kaggle.com
Format: Imported into SQL Server Management Studio from Excel

The raw dataset includes:

Booking details

Arrival dates split across multiple columns

Guest counts

Pricing metrics (ADR (Average Daily Rates))

Market and customer segmentation

Personally Identifiable Information (PII)

🔹 Data Architecture

The project follows a layered data model:

Raw Table (immutable)
        ↓
Cleaned View (standardized)
        ↓
Analytics View (business metrics & KPIs)

Why this matters:

Prevents accidental data loss

Ensures auditability

Aligns with industry best practices

🔹 Raw Table
dbo.hotel_bookings_raw


Key characteristics:

Mirrors the original Excel file

Contains PII (name, email, phone, credit card)

Never modified directly

🔹 Data Cleaning Strategy

The cleaning logic is implemented using SQL views, not destructive updates.

Key Cleaning Steps:

Profiled the data to identify NULLs, invalid values, and inconsistencies

Standardized column names for SQL compatibility

Reconstructed arrival dates from year/month/day columns

Handled NULLs intentionally using business logic

Validated numeric ranges (e.g., negative ADR values)

Removed PII from analytics views

Created derived business metrics

🔹 Cleaned Analytics View
dbo.vw_hotel_bookings_clean

Key Transformations:

Rebuilt arrival_date using DATEFROMPARTS

Standardized numeric fields

Excluded PII fields

Ensured ADR values are valid

Preserved raw data integrity

🔹 Business Metrics Added

The following derived metrics were created to support analysis:

Total Nights Stayed

stays_in_week_nights + stays_in_weekend_nights


Total Booking Revenue

adr * total_nights


These metrics enable revenue, cancellation, and customer behavior analysis.

🔹 Final Analytics View
dbo.vw_hotel_analytics

Includes:

Arrival day of week

Customer type

Market segment

Cancellation status

Total nights

Estimated booking revenue

This view is dashboard-ready and can be connected directly to Tableau or Power BI.

🔹 Data Quality Checks

The project includes validation queries to identify:

Impossible guest counts

Negative or extreme ADR values

Abnormal booking durations

These checks can be automated or scheduled in production systems.

🛠 Tools & Technologies

SQL Server (T-SQL)

Excel (data ingestion)

SQL Views

GitHub (version control)

🔹 Use Cases

This dataset can be used to analyze:

Cancellation rates

Revenue trends

Seasonal demand

Customer segmentation

Booking behavior by day of week

🔹 Key Takeaways

Raw data should never be modified

PII should never appear in analytics layers

Business context is as important as technical correctness

SQL views are powerful tools for scalable data cleaning

🔹 Interview Talking Point

“I ingested raw booking data, profiled it, reconstructed dates, handled NULLs based on business rules, removed PII from analytics views, and built an analytics-ready SQL layer without altering the raw data.”

🔹 Future Improvements

Add automated SQL data quality tests

Create a star schema for reporting

Integrate with Tableau Public

Calculate additional hotel KPIs (RevPAR, Occupancy Rate)

👤 Author

Long Nguyen
Aspiring Data Analyst | SQL | Data Cleaning | Analytics Engineering
