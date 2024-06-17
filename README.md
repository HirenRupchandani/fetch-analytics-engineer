# fetch-analytics-engineer-takehome-assessment
A Take Home Assessment designed by Fetch Rewards for the Analytics Engineer Position.

## First Task: Review Existing Unstructured Data and Diagram a New Structured Relational Data Model
The data has 3 tables - users, brands. amd receipts. Based on the dataset schema provided, here is how the relation can be formed between these 3 tables:
- User's _id$oid key can be set as a foreign key in receipts using the userId key. 
- This relation can be defined as a one to many cardinality relation as a user can have multiple receipts.
- Brand's brandCode key can be set as a foreign key in receipts using the rewardsReceiptItemList.brandCode or rewardsReceiptItemList.barcode keys.
- This relation can also be defined as a one to many cardinality relation as a brand can be bought multiple times so it can appear in many receipts many times.
- rewardsReceiptItemList can be imagined as a separate derived table that has many fields withing itself. In this derived table, we can use receipts._id and receipts.userId to refer to this table for all the items in each receipt. 
- We can't form any direct relation between users and brands.
- Here is a simplified and structured diagram of the said tables:
![ER Diagram](https://raw.githubusercontent.com/HirenRupchandani/fetch-analytics-engineer/main/ERDiagram.png)

## Second Task: Write queries that directly answer predetermined questions from a business stakeholder

- Dialect Used: MySQL
- You can use the SQL dump file to ensure data integrity before testing the queries.
- After the data is imported for users, brands, receipts, and items, You can run the fetch-queries.sql file in one go to display all the outputs.

### **Question 1**: What are the top 5 brands by receipts scanned for most recent month?

- **Approach:** 
- A LastMonthReceipts CTE that filters all the receipts that were scanned since 1 Month  to the latest value of scanned dates which appears to be March 1, 2021.
- So the range is Febrauary 1, 2021 - March 1, 2021 both inclusive.
- Using the above CTE, all the items are extracted by matching the filtered receipt ID across items and receipts tables. brandCode is what we are searching for in the result. So we create a new CTE that has receipt id, userId, and brandcode from Items table.
- Using the brandCodes we found, we create groups of all the brands and check their count, sort them in non-increasing order and check the first 5 brands.

- **Observation:** We found BRAND, MISSION, and VIVA as the top brandCodes.

### **Question 2**: How does the ranking of the top 5 brands by receipts scanned for the recent month compare to the ranking for the previous month?

- **Approach:** We just expand the logic used above for previous 2 months.
- Step 1: Identify receipts scanned in the recent month
- Step 2: Identify receipts scanned in the previous month
- Step 3: Join Items table with RecentMonthReceipts to get brandCode
- Step 4: Join Items table with PreviousMonthReceipts to get brandCode
- Step 5: Count receipts by brandCode for the recent month
- Step 6: Count receipts by brandCode for the previous month
- Step 7: Combine and compare rankings using a UNION.

- **Observation:** BRAND and MISSION are way below with scanned counts at 19 and 16 respectively.
- VIVA is not in the list. The list is dominated by Hy-Vee which is a chain of supermarkets in the Midwestern US. 
- The count of Hy-Vee is at 291 and the following brand is Ben And Jerrys with a count of 180.

### **Question 3**: When considering average spend from receipts with 'rewardsReceiptStatus' of 'Accepted' or 'Rejected', which is greater?

- **Approach:** We will first calculate the average amount spent for Accepted status which is assumed to be "FINSIHED" status and "REJECTED" status receipts
- We then compare these averages to determine which status has a higher average spent and display the result with the respective average values calculated.

- **Observation:**
'Accepted' (FINISHED) receipts show a higher average spent compared to 'Rejected' receipts.

### **Question 4**: When considering total number of items purchased from receipts with 'rewardsReceiptStatus' of 'Accepted' or 'Rejected', which is greater?

- **Approach:** 
- We are using the same logic as query 3, except that now we will check the average item count:
- Calculate the average number of items purchased for receipts marked as 'FINISHED' (Accepted) and 'REJECTED' (Rejected). Compare the averages to determine which status has a higher average number of items purchased. 
- Display the comparison result along with the respective average item counts.

- **Observation:** The Average Item count for accepted status is more than that of rejected status

### **Question 5**: Which brand has the most spend among users who were created within the past 6 months?

- **Approach:**
- **Assumption**: Checking users created in the last 6 months where the latest date is the date where the last user is created which stands at February 12, 2021. So we will take a 6 month interval of users created in the last 6 months till 02/12/2021. Which stands at February 12, 2021. So we will take a 6 month interval of users created in the last 6 months till 02/12/2021.
- The rest of the query is a simple grouping of brandCodes where we calculate the sum of finalPrices of receipts for all brandCodes and check the first brand name after sorting the result in non-increasing order.

- **Observation:** Ben And Jerrys have the most spend among the users created in the last 6 months

### **Question 6**: Which brand has the most transactions among users who were created within the past 6 months?

**Approach:**  
- Similar logic as Query 5 except we check the receipts counted after grouping by brandCodes.
- Sorting is done in non-increasing order followed by checking the first value.

**Observation:**
- Hy-Vee has the most transactions across all the users created in the last 6 months.

# Third Task: Evaluate Data Quality Issues in the Data Provided

- Language of choice: Python3
- Libraries used: JSON, Pandas, NumPy
- You can directly run this notebook. Only the original json files are required along with the JSON, Pandas, and NumPy libraries.

## **Users** Table
#### JSON to CSV:
- The data was read using json library and normalized using pandas. This helped in extracting the nested fields that are set as the columns of the table.
- Date columns are casted to appropriate datetime data type and empty dates are replaced by empty string.
- The dataframe is saved as a CSV file

#### Data Cleaning:
- On the first glance, we can see the id, active status, role, signUpSource, createdDate, and lastLogin fields. These are self explanatory but can be explored further.
- There are 495 rows but a lot of them are duplicates. There are just 212 unique user IDs. 
- There are some fields with missing values such as signUpSource, state, amd lastLogin.

- Correcting the Date columns into proper format: '%Y-%m-%d %H:%M:%S.%f' and filling the lastlogin column using 2 strategies:
1. If a user ID is repeated, check if other rows of the same user ID have a lastlogin value, if yes, use that value.
2. If a user IDs all instances have lastlogin as NULL, fill the value with the created date as the user must be logged in for the first time when the account was created.
- Filling the missing values in singUpSource and state using the same strategy 1 as lastLogin. But none of the cells got filled using this strategy
- There are plenty observations noted in the `fetch-data-cleaning.ipynb` notebook or `fetch-data-cleaning.pdf` such as one account being inactive and presence of fetch-staff in users.

#### Questions/Concerns:
- Why do we have redundant user data?
- What caused the one account of the userID `6008622ebe5fc9247bab4eb9` to go inactive?
- Why and how are some of the users fetch-staff?
- What are the other signup sources?
- What is the cause of lastLogin being a missing value? Is this a data validation problem?


## **Brands** Table
#### JSON to CSV:
- Similar strategy used just like Users. Just renamed some columns for easier readability and reference.
- Saved teh dataframe as a CSV file.

#### Data Cleaning:
- There are many missing values in this table but thankfully, no duplicated rows.
- Since there are string values in this dataset, I removed the leading and trailing spaces that might cause some mismatch during the queries.
- There were missing values in topBrand which lead to an assumption: 
-- I am listing NULL topBrands as False. Because if they were important to be noted as Top Brand, the value should have been present.
- Also performed some type casting to int for topBrands for easier data import in MySQL.
- Assuming Categories have corresponding category codeand since a lot of category codes are missing, I have filled those codes with corresponding category's mode.

#### Questions/Concerns:
- barcode is self-explanatory but there seem to be no clear distinction between the category and categoryCode columns.
- Similarly, there is a name overlap between name and brandCode.
- It is understood that the brandCode is under the umbrella of category/categoryCode.
- TopBrand indicates what a popular or top brand might be but what is the criteria for a brand to become topBrand?
- There are some NaNs listed as top brands. What is the reason for this inconsistency?
- name has a lot of dummy/test values. It would be helpful to get a source/reason for these values.
- It can be observed that the test brand names are not listed as top brands.
- A clear distinction between these columns will give a good indication on how to use these columns efficiently.

## **Receipts** Table
#### JSON to CSV:
- Similar strategy to the previous 2 tables. But this time, the rewardsReceiptItemList was normalized further into a derived table called items.
- The derived table has 34 more fields and tells about the items in each receipt.

#### Data Cleaning:
- Not all the fields with null values are dealt with since it might change the meaning of some fields.
- There are no duplicates in the table.
- Performed some renaming of the columns to remove the `$` suffixes.
- Casted the date based columns to datetime datatype.
- Filled the null values of bonusPointsEarned and totalSpent to 0 and recasted them to FLOAT datatype for easier import into MySQL.
- The columns purchasedItemCount and bonusPointsEarned are skewed towards right as their mean is significantly higher than the median. This could be a result of the max values in both the columns being very high.
- Removing the outlier from purchasedItemCount (689 items purchased in a single receipt!) results in a fairly symmetric distribution but the same approach does not work for bonusPointsEarned (has a high 75th percentile value and even higher maximum value as compared to the median value).
- Perhaps some brands give more bonus points as compared to other brands? Does this **correlate** to these brands being **topBrands** in the brands table?
- There are many other data cleaning steps that can be performed on this table, but given the business requirements, this much data cleaning is sufficient. Other cleaning steps can be performed as per the client's/stakeholder's requirements.

#### Questions/Concerns:
- There are many userIds and brandCodes/barcodes that are not present in the users and brands tables respectively. 
- I would like to assume that we are given a subset of each table without any validation for the appropriate users and brands.
- Since this inconsistency exists, a foreign key relation cannot be established between users and receipts as well as items and brands.

### Items Table (Derived from Receipts)
- No cleaning was performed except some renaming of fields for easier access. 
- Again, a foreign key relationship cannot be established with users and brands but we can point to specific userIds and brandCodes or barcodes.
- There are inconsistencies between barcodes present in brands and the ones present in items. Is there are different subset of barcodes or is there any validation error?

# Fourth Task: Communicate with Stakeholders:

Dear Product/Business Leader,

I have thoroughly analyzed the provided data and identified several data quality issues and concerns. Here are the key points:

**Questions about the Data**:
- Why do we have redundant user data with duplicate user IDs?
- What caused the one account (userID 6008622ebe5fc9247bab4eb9) to become inactive?
- Why and how are some users labeled as "fetch-staff"? What is the significance of this?
- What are the other signup sources besides the ones present in the data?
- What is the cause of missing lastLogin values for some users? Is this a data validation issue?
- Why are there inconsistencies between barcodes present in the brands table and the items table?
- What is the criteria for a brand to be considered a "topBrand"? Why are there NaN values listed as top brands?
- Why are there dummy/test values present in the "name" column of the brands table?
- There are many userIds and brandCodes/barcodes in the receipts table that are not present in the users and brands tables respectively. How can we establish proper relationships between these tables?

**Data Quality Issues**:

I discovered the data quality issues through a thorough data cleaning and exploration process. This involved:
- Checking for missing values, duplicates, and inconsistencies across all tables.
- Examining the data types (especially for date type columns that were in unix timestamp and converted them to human readable format) and formats of columns to ensure consistency.
- Analyzing the relationships and dependencies between tables to identify potential issues with foreign key constraints. This can be seen in receipts 
table where certain users and brands appear in the receipts, that are not present in either users and brands tables
- Investigating outliers and anomalies in the data. What caused a significant rise in points gained for some users. Is there are relationship between any columns that resulted in this?

**Resolving Data Quality Issues**:

To resolve the identified data quality issues, we need:
- Clear documentation and understanding of the data sources, collection processes (signup sources, login dates, calculation of points, etc.), and business rules (user roles, topBrand calculations, partners, brand categorization, etc.).
- The data seems to be of NoSQL type since the source was in JSON format. What kind of data model is used for the creation of this data?
- Collaboration with subject matter experts to clarify ambiguities and validate assumptions made for this data analysis.
- Established data governance policies and procedures for data validation, cleansing, and standardization.
- Robust data quality monitoring and reporting mechanisms to identify and address issues proactively.

**Optimizing Data Assets**:
- Detailed business requirements and use cases for the data. This might include "what is needed from this data"? "Where is it stored?"
- Noting the performance and scalability requirements for the intended applications or analytics. 
- Data privacy and security considerations. Are we following the rules and are compliant with the regulations for data privacy and security of the users?
- Existing data infrastructure and technology stack to assess integration and compatibility.
- Certain automations can be performed to ensure data validation.

**Performance and Scaling Concerns**:
- Implementing efficient indexing strategies (for easier row access) for frequently queried columns and joins.
- Partitioning/Normalizing large tables based on access patterns or data distribution. This can be done for tables that are not frequently queried and are very large.
- Caching frequently accessed data (lastLogin details, topBrands) or query results to reduce database load.
- Leveraging distributed computing frameworks or cloud-based solutions for scalability.

I hope this information provides a comprehensive overview of the data quality issues, concerns, and potential solutions. Please let me know if you need any further clarification or have additional requirements.

Best regards,
Hiren Rupchandani
