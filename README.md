# Power BI Logistics Performance Analysis

## Overview
This project focuses on analyzing logistics performance using Power BI. The dataset includes details about orders, customers, sales, and product insights, allowing us to evaluate business performance based on key metrics.

## Data Preparation and Cleaning
Before building the Power BI dashboard, the dataset underwent a thorough cleaning and transformation process:
1. **Data Cleaning**:
   - Removed duplicate records to avoid inconsistencies.
   - Handled missing values by filling in reasonable defaults or omitting irrelevant data.
   - Standardized date formats to ensure consistency in time-based analysis.
   - Normalized categorical fields (e.g., product categories, customer segments) for accurate grouping.

2. **Data Transformation**:
   - Created calculated columns to derive insights such as profit margins and order processing times.
   - Extracted key time-based attributes (e.g., year, month) for trend analysis.
   - Established relationships between different tables (Orders, Customers, Products, Employees) to facilitate dynamic analysis.

## Data Model Structure
The data model in Power BI consists of multiple interconnected tables:
- **Orders Table**: Contains order details such as order ID, date, shipping mode, and sales amount.
- **Customers Table**: Includes customer demographics, segment classification, and regional distribution.
- **Products Table**: Features product categories, subcategories, and pricing information.
- **Employees Table**: Maintains sales representative details for performance tracking.

Relationships between these tables are established based on unique identifiers such as Customer ID, Order ID, and Product ID, enabling seamless cross-analysis.

## Dashboard Insights
### **1. Overview Dashboard**
This dashboard provides a high-level summary of business performance:
- **Total Sales**: $2.30M, with a 20% year-over-year growth.
- **Total Profit**: $286K, reflecting a 14% increase compared to the previous year.
- **Total Orders**: 5009, showing a 28% rise in order volume.
- **Sales Trends**: Monthly sales trends indicate seasonality, with peaks in March and November.
- **Profitability by Region**: The West and East regions contribute the highest profit, while South Central lags behind.

### **2. Logistics Performance Dashboard**
This dashboard evaluates operational efficiency and logistics effectiveness:
- **Order Processing Time**:
  - First Class: 2.5 days (fastest processing time)
  - Standard Class: 5.5 days (slowest processing time)
  - Certain states, such as North Dakota and West Virginia, have shorter processing times, whereas states like the District of Columbia and Maine experience delays.
- **Total Cost of Goods Sold (COGS)**:
  - California and New York incur the highest logistics costs.
  - Ohio and Texas show negative profit margins, indicating potential inefficiencies or high operational expenses.

### **3. Product & Customer Insights Dashboard**
This section focuses on customer behaviors and product performance:
- **Customer Insights**:
  - Most repeated customer: Emily Phan.
  - Top 10 customers contribute significantly to repeat purchases.
- **Product Performance**:
  - Best-selling product: Staples.
  - Top sales categories: Technology, Furniture, and Office Supplies.
  - Copiers and Phones generate the highest profit, while Fasteners and Bookcases perform poorly.
- **Profitability by Product Sub-Category**:
  - Labels, Paper, and Envelopes have the highest profit margins.
  - Machines and Bookcases show negative profitability.

## How to Use
1. **Download the Power BI file** (`Logistics Project.pbix`).
2. Open it using [Power BI Desktop](https://powerbi.microsoft.com/en-us/downloads/).
3. Explore different dashboards:
   - **Overview Dashboard**: Key metrics and trends.
   - **Logistics Performance**: Shipping analysis, order processing times.
   - **Product & Customer Insights**: Best-selling products, repeat customers, profit distribution.

## Installation
Ensure you have Power BI installed before opening the `.pbix` file. If necessary, update your dataset sources to match the file paths on your system.

## Conclusion
This Power BI report offers a detailed view of logistics performance, customer insights, and sales trends. By analyzing key metrics such as order processing times, profit margins, and customer purchasing patterns, businesses can optimize their operations and enhance profitability.

## Contact
For any inquiries, feel free to connect via GitHub or email.
