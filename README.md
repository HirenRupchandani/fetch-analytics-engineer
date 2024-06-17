# fetch-analytics-engineer-takehome-assessment
A Take Home Assessment designed by Fetch Rewards.
## Second Task: Write queries that directly answer predetermined questions from a business stakeholder

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
