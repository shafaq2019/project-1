# project-1# Northwind — Sales & Revenue Analysis

Project summary
- This repository contains an analysis of the Northwind sample database to explore revenue drivers, customer value, product performance, and temporal trends. The goal is to extract business-ready insights (top products, top customers, monthly/quarterly revenue, AOV, RFM segmentation) using SQL, Excel, and Power BI.

Why this project
- Northwind is a classic sample sales dataset ideal for practicing joins, aggregations, time-series analysis, and dashboarding. This project demonstrates how to combine order details with orders (including freight) to compute true revenue per order and per customer, and to create dashboards and simple forecasts.

What I did
- Cleaned and joined order details with orders to include freight in revenue calculations.
- Computed order-level, product-level and customer-level revenue metrics.
- Built RFM (recency, frequency, monetary) measures and identified top customers.
- Created monthly, quarterly, and yearly revenue time series and visualized them in dashboards.

Notes & tips
- Freight treatment: I used COALESCE(o.Freight,0) to avoid NULL propagation.
- Use DATE_FORMAT or EXTRACT functions depending on your SQL dialect (MySQL shown here). For PostgreSQL, replace DATE_FORMAT with to_char(date,'YYYY-MM').
- Store sometimes has different column names; confirm table and column names in your Northwind copy.
