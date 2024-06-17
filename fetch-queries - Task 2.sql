-- Query 1: What are the top 5 brands by receipts scanned for most recent month?

-- A LastMonthReceipts that filters all the receipts that were scanned since 1 Month
-- to the latest value of scanned dates which appears to be March 1, 2021.
-- So the range is Febrauary 1, 2021 - March 1, 2021 both inclusive
WITH LastMonthReceipts AS (
SELECT userId, _id
FROM receipts r 
WHERE dateScanned >= (
SELECT DATE_SUB(MAX(dateScanned), INTERVAL 1 MONTH)
FROM receipts)),

-- Using the above CTE, all the items are extracted by matching the filtered receipt ID across
-- Items and Receipts tables. brandCode is what we are searching for in the result.
LastMonthItems AS (SELECT i.userId, i._id, i.brandCode
FROM items i
INNER JOIN LastMonthReceipts l
ON i._id = l._id
WHERE i.brandCode IS NOT NULL
AND i.brandCode != '')

-- Using the itemset/brandCodes we found, we create groups of all the brands
-- and check their count, sort them in non-increasing order and check the first 5 brands
SELECT lm.brandCode, count(*) as receipt_count
FROM LastMonthItems lm
GROUP BY lm.brandCode
ORDER BY receipt_count DESC
LIMIT 5;
-- Observation: : We found BRAND, MISSION, and VIVA as the top brandCodes.

-- ---------------optional------------------

-- The below additional CTE and following Query check the found brands in the brands table.
-- The goal was to see if any of the found brands are listed as topBrand in the Brands table.
-- But only VIVA is present in the Brands table and it is not marked as a topBrand. So the query
-- has been archived and can be discussed with the client in future.

-- , TopBrands AS (
--     SELECT brandCode, COUNT(*) AS receipt_count
--     FROM LastMonthItems
--     GROUP BY brandCode
--     ORDER BY receipt_count DESC
--     LIMIT 5
-- )

-- SELECT tb.brandCode, b.name, b.topBrand
-- FROM TopBrands tb
-- INNER JOIN Brands b ON tb.brandCode = b.brandCode
-- ORDER BY tb.receipt_count DESC; 
-- Output is Viva, VIVA, False
-- ---------------optional------------------


-- Query 2: How does the ranking of the top 5 brands by receipts scanned for the recent month compare to the ranking for the previous month?
-- We just expand the logic used above for previous 2 months
-- Step 1: Identify receipts scanned in the recent month
WITH RecentMonthReceipts AS (
    SELECT userId, _id
    FROM Receipts
    WHERE dateScanned >= DATE_SUB((SELECT MAX(dateScanned) FROM Receipts), INTERVAL 1 MONTH)
),

-- Step 2: Identify receipts scanned in the previous month
PreviousMonthReceipts AS (
    SELECT userId, _id
    FROM Receipts
    WHERE dateScanned >= DATE_SUB((SELECT MAX(dateScanned) FROM Receipts), INTERVAL 2 MONTH)
      AND dateScanned < DATE_SUB((SELECT MAX(dateScanned) FROM Receipts), INTERVAL 1 MONTH)
),

-- Step 3: Join Items table with RecentMonthReceipts to get brandCode
RecentMonthItems AS (
    SELECT i.userId, i._id, i.brandCode
    FROM Items i
    INNER JOIN RecentMonthReceipts rmr ON i._id = rmr._id
    WHERE i.brandCode IS NOT NULL AND i.brandCode != ''
),

-- Step 4: Join Items table with PreviousMonthReceipts to get brandCode
PreviousMonthItems AS (
    SELECT i.userId, i._id, i.brandCode
    FROM Items i
    INNER JOIN PreviousMonthReceipts pmr ON i._id = pmr._id
    WHERE i.brandCode IS NOT NULL AND i.brandCode != ''
),

-- Step 5: Count receipts by brandCode for the recent month
RecentMonthTopBrands AS (
    SELECT brandCode, COUNT(*) AS receipt_count
    FROM RecentMonthItems
    GROUP BY brandCode
    ORDER BY receipt_count DESC
    LIMIT 5
),

-- Step 6: Count receipts by brandCode for the previous month
PreviousMonthTopBrands AS (
    SELECT brandCode, COUNT(*) AS receipt_count
    FROM PreviousMonthItems
    GROUP BY brandCode
    ORDER BY receipt_count DESC, brandCode
)

-- Step 7: Combine and compare rankings
SELECT 
    r.brandCode AS recentBrandCode,
    r.receipt_count AS recentReceiptCount,
    p.brandCode AS previousBrandCode,
    p.receipt_count AS previousReceiptCount
FROM 
    RecentMonthTopBrands r
LEFT JOIN 
    PreviousMonthTopBrands p ON r.brandCode = p.brandCode

UNION

SELECT 
    r.brandCode AS recentBrandCode,
    r.receipt_count AS recentReceiptCount,
    p.brandCode AS previousBrandCode,
    p.receipt_count AS previousReceiptCount
FROM 
    RecentMonthTopBrands r
RIGHT JOIN 
    PreviousMonthTopBrands p ON r.brandCode = p.brandCode
ORDER BY 
    recentReceiptCount DESC, previousReceiptCount DESC;
-- Observation: BRAND and MISSION are way below with scanned counts at 19 and 16 respectively.
-- VIVA is not in the list. The list is dominated by Hy-Vee which is a chain of supermarkets in the Midwestern US 
-- The count of Hy-Vee is at 291 and the following brand is Ben And Jerrys with a count of 180.

-- Query 3: When considering average spend from receipts with 'rewardsReceiptStatus' of 'Accepted' or 'Rejected', which is greater?
-- We will first calculate the average amount spent for Accepted status which is assumed to be "FINSIHED" status and "REJECTED" status receipts
-- We then compare these averages to determine which status has a higher average spent
-- and display the result with the respective average values calculated.
WITH AverageSpent AS (
    SELECT 
        rewardsReceiptStatus,
        ROUND(SUM(totalSpent) / COUNT(*), 3) AS averageSpent
    FROM receipts
    WHERE rewardsReceiptStatus IN ('FINISHED', 'REJECTED')
      AND totalSpent IS NOT NULL
    GROUP BY rewardsReceiptStatus
)

SELECT 
    CASE 
        WHEN f.averageSpent > r.averageSpent
            THEN 'Accepted > Rejected for Average Spent on Items'
        ELSE 'Rejected > Accepted for Average Spent on Items'
    END AS statusType,
    f.averageSpent AS acceptedAverageSpent,
    r.averageSpent AS rejectedAverageSpent
FROM 
    (SELECT averageSpent FROM AverageSpent WHERE rewardsReceiptStatus = 'FINISHED') f,
    (SELECT averageSpent FROM AverageSpent WHERE rewardsReceiptStatus = 'REJECTED') r;
-- Observation: We can see that Average Spent for accepted status is more than that of rejected status

-- Query 4: When considering total number of items purchased from receipts with 'rewardsReceiptStatus' of 'Accepted' or 'Rejected', which is greater?
-- We are using the same logic as query 3, except that now we will check the average item count
-- instead of average total spending for each status. Here is the query:
WITH AverageItemCount AS (
    SELECT 
        rewardsReceiptStatus,
        ROUND(SUM(purchasedItemCount) / COUNT(*)) AS averageItemCount
    FROM receipts
    WHERE rewardsReceiptStatus IN ('FINISHED', 'REJECTED')
      AND purchasedItemCount IS NOT NULL
    GROUP BY rewardsReceiptStatus
)

SELECT 
    CASE 
        WHEN f.averageItemCount > r.averageItemCount
            THEN 'Accepted > Rejected for Average Item Count'
        ELSE 'Rejected > Accepted for Average Item Count'
    END AS statusType, 
    GREATEST(f.averageItemCount, r.averageItemCount) AS averageItemCount
FROM 
    (SELECT averageItemCount FROM AverageItemCount WHERE rewardsReceiptStatus = 'FINISHED') f,
    (SELECT averageItemCount FROM AverageItemCount WHERE rewardsReceiptStatus = 'REJECTED') r;
-- Observation: The Average Item count for accepted status is more than that of rejected status

-- Query 5: Which brand has the most spend among users who were created within the past 6 months?
-- Assumption: Checking users created in the last 6 months where the latest date is the date where the last user is created
-- Which stands at February 12, 2021. So we will take a 6 month interval of users created in the last 6 months till 02/12/2021.
-- The rest of the query is a simple grouping of brandCodes where we calculate the sum of finalPrices of receipts for all brandCodes
-- and check the first brand name after sorting in non-increasing order.
WITH usersInLast6Months AS (
	SELECT * 
    FROM users u
    WHERE u.createdDate >= DATE_SUB((SELECT MAX(createdDate) FROM users), INTERVAL 6 MONTH)
)
SELECT i.brandCode, round(sum(i.finalPrice), 3) AS totalSpentOnBrand
FROM items i
INNER JOIN usersInLast6Months u6m
ON i.userId = u6m._id
WHERE i.brandCode != ''
GROUP BY i.brandCode
ORDER BY totalSpentOnBrand DESC
LIMIT 1;
-- Observation: Ben And Jerrys have the most spend among the users created in the last 6 months


-- Query 6: Which brand has the most transactions among users who were created within the past 6 months?
-- Similar logic as Query 5 except we check the receipts counted after grouping by brandCodes
-- Sorting in non-increasing order and checking the first value.
WITH usersInLast6Months AS (
	SELECT * 
    FROM users u
    WHERE u.createdDate >= DATE_SUB((SELECT MAX(createdDate) FROM users), INTERVAL 6 MONTH)
)
SELECT i.brandCode, count(i._id) AS brandTransactions
FROM items i
INNER JOIN usersInLast6Months u6m
ON i.userId = u6m._id
WHERE i.brandCode != ''
GROUP BY i.brandCode
ORDER BY brandTransactions DESC
LIMIT 1;
-- Observation: Hy-Vee has the most transactions across all the users created in the last 6 months.


