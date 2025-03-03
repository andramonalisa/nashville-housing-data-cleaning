# 🏡 Nashville Housing Data Cleaning  
### Transforming Raw Real Estate Data into a Clean, Structured Dataset  

---

## 📌 Overview  
Hey there! Welcome to my **Nashville Housing Data Cleaning** project. As a junior data analyst, I tackled raw, messy real estate data and turned it into a clean, structured, and analysis-ready dataset using **SQL (Snowflake)**.  

This project highlights my skills in **data wrangling, cleaning, and transformation**—because let’s be real, no analysis is fun with dirty data!  

---

## 📂 Project Files  
📌 **Nashville_Housing_Cleaned.csv** – The cleaned dataset  
📌 **Nashville_Housing_Cleaned.sql** – SQL script used for data cleaning  
📌 **README.md** – You’re reading it!  

---

## 📊 What Was Done? (Cleaning Steps)  
Here’s a quick breakdown of the data cleaning process:  

🔹 **Renamed columns** for consistency (e.g., `SALE_DATE` → `sale_date`)  
🔹 **Removed duplicates** to avoid double-counting sales  
🔹 **Handled missing values**:  
   - Filled missing `owner_name` with **'Unknown'**  
   - Used **median values** for `year_built`, `bedrooms`, and `bathrooms`  
   - Replaced `land_value` and `building_value` using **median per tax district**  
🔹 **Standardized addresses** (separated city & street)  
🔹 **Formatted dates** for better readability  

All done in **SQL** because, let’s face it, **Excel can only take us so far!** 🚀  

---

## 📈 Skills Used  
✅ **SQL (Snowflake)** – Data transformation & querying  
✅ **Data Cleaning** – Handling missing data, duplicates, and inconsistencies  
✅ **Data Standardization** – Ensuring uniform formatting  
✅ **Using Window Functions** – For deduplication and imputation  

---

## 🎯 Lessons Learned  
✔ **Data cleaning is 80% of the work** in data analysis  
✔ **SQL is a superpower** for handling large datasets  
✔ **Always check for duplicates**—they hide everywhere!  

---

## 🚀 Installation & Usage 
To explore the cleaned dataset:  
1. **Download** the dataset from [[Nashville Housing Data for Data Cleaning.xlsx](https://github.com/AlexTheAnalyst/PortfolioProjects/blob/39c541bae76eb109652e8d834b0fa2aa3f15fd8b/Nashville%20Housing%20Data%20for%20Data%20Cleaning.xlsx)].  
2. **Import** the dataset into a SQL database (e.g., **Snowflake, MySQL, PostgreSQL**).  
3. **Run queries** on the cleaned data to uncover insights.  

---

## 🐞 Known Issues   
- Occasional **duplicate entries** not yet fully filtered.  
- Certain **address formats** may still need refinement.   

---

## 📬 Connect With Me  
Let’s talk data! You can find me on:  
💼 **LinkedIn**: [andramonalisa](https://www.linkedin.com/in/andramonalisa/) 

---

Thanks for stopping by! Happy querying! 🎉  
