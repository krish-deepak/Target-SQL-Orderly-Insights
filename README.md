
## 📊 Target SQL: Orderly Insights

### 🧠 Project Overview
This project presents a comprehensive SQL-based analysis of Target's Brazilian e-commerce data. The goal is to uncover customer behavior, order trends, delivery performance, and payment patterns to derive actionable business insights.

---

### 📁 Dataset Overview
https://drive.google.com/drive/folders/1TGEc66YKbD443nslRi1bWgVd238gJCnb  (Can download data from here)

The analysis is based on multiple tables including:
- `customers`
- `orders`
- `order_items`
- `payments`
- `sellers`
- `geolocations`
- `Reviews`
- `products`

Time range of data: **September 2016 to October 2018**

---

### 🔍 Key Analyses Performed

#### 🧱 Exploratory Data Analysis
- Data types of all columns in the `customers` table
- Time range of orders
- Count of unique cities and states with customer orders

#### 📈 Trend & Seasonality
- Year-over-year growth in order volume
- Monthly seasonality patterns
- Time-of-day analysis for order placement (Dawn, Morning, Afternoon, Night)

#### 🌎 Regional Insights
- Month-on-month order volume by state
- Customer distribution across Brazilian states

#### 💰 Economic Impact
- 136% increase in order value from Jan–Aug 2017 to Jan–Aug 2018
- Total and average order price and freight value by state

#### 🚚 Delivery Performance
- Actual delivery time vs. estimated delivery time
- Top 5 states with:
  - Highest & lowest average freight
  - Fastest & slowest delivery times
  - Best performance compared to estimated delivery

#### 💳 Payment Analysis
- Monthly order volume by payment type
- Distribution of payment installments (most orders paid in a single installment)

---

### 🛠️ Tools & Technologies
- **SQL** (Google BigQuery)
- **Google Cloud Platform**
- **Data Visualization** (via screenshots in the PDF)

---

### 📌 Key Insights
- Afternoon is the most popular time for placing orders.
- São Paulo (SP) dominates in customer count and order volume.
- Credit cards are the most used payment method.
- Delivery performance varies significantly by state, with some states consistently outperforming estimated delivery times.

---


