CREATE TABLE Users (
    _id VARCHAR(255) PRIMARY KEY,
    active INT NOT NULL,
    role VARCHAR(255) NOT NULL,
    signUpSource VARCHAR(255),
    state VARCHAR(255),
    createdDate DATETIME NOT NULL,
    lastLogin DATETIME NOT NULL
);

CREATE TABLE Brands (
    _id VARCHAR(255) PRIMARY KEY,
    barcode BIGINT NOT NULL,
    category VARCHAR(255),
    categoryCode VARCHAR(255),
    name VARCHAR(255) NOT NULL,
    topBrand INT NOT NULL,
    brandCode VARCHAR(255),
    cpg_id VARCHAR(255) NOT NULL,
    cpg_ref VARCHAR(255) NOT NULL
);

CREATE TABLE Receipts (
    _id VARCHAR(255) PRIMARY KEY,
    bonusPointsEarned FLOAT NULL DEFAULT NULL,	
    bonusPointsEarnedReason VARCHAR(255),
    createDate DATETIME NOT NULL,
    dateScanned DATETIME NOT NULL,
    finishedDate DATETIME NULL DEFAULT NULL,
    modifyDate DATETIME NOT NULL,
    pointsAwardedDate DATETIME NULL DEFAULT NULL,
    pointsEarned TEXT,
    purchaseDate DATETIME NULL DEFAULT NULL,
    purchasedItemCount TEXT,
    rewardsReceiptStatus VARCHAR(255) NOT NULL,
    totalSpent TEXT,
    userId VARCHAR(255) NOT NULL
);

-- Option 1: Temporarily disable safe update mode
SET SQL_SAFE_UPDATES = 0;

-- Check for non-numeric values in totalSpent, pointsEarned, purchasedItemCount
SELECT * FROM Receipts WHERE CAST(totalSpent AS DECIMAL) IS NULL AND totalSpent IS NOT NULL;
SELECT * FROM Receipts WHERE CAST(purchasedItemCount AS DECIMAL) IS NULL AND purchasedItemCount IS NOT NULL;
SELECT * FROM Receipts WHERE CAST(pointsEarned AS DECIMAL) IS NULL AND pointsEarned IS NOT NULL;
-- Step 2: Update empty strings to NULL
UPDATE Receipts SET purchasedItemCount = NULL WHERE purchasedItemCount = '';
UPDATE Receipts SET pointsEarned = NULL WHERE pointsEarned = '';
UPDATE Receipts SET totalSpent = NULL WHERE totalSpent = '';
-- Step 3: Update non-numeric values to NULL
UPDATE Receipts SET purchasedItemCount = NULL WHERE CAST(purchasedItemCount AS DECIMAL) IS NULL;
UPDATE Receipts SET pointsEarned = NULL WHERE CAST(pointsEarned AS DECIMAL) IS NULL;
UPDATE Receipts SET totalSpent = NULL WHERE CAST(totalSpent AS DECIMAL) IS NULL;
-- Step 4: Alter the column type
ALTER TABLE Receipts MODIFY COLUMN purchasedItemCount DOUBLE NULL DEFAULT NULL;
ALTER TABLE Receipts MODIFY COLUMN pointsEarned DOUBLE NULL DEFAULT NULL;
ALTER TABLE Receipts MODIFY COLUMN totalSpent DOUBLE NULL DEFAULT NULL;

SELECT * FROM Receipts;

CREATE TABLE Items (
    barcode VARCHAR(255) NULL,
    description TEXT NULL,
    finalPrice TEXT NULL,
    itemPrice TEXT NULL,
    needsFetchReview VARCHAR(255) NULL,
    partnerItemId BIGINT NOT NULL,
    preventTargetGapPoints VARCHAR(255) NULL,
    quantityPurchased TEXT NULL,
    userFlaggedBarcode TEXT NULL,
    userFlaggedNewItem VARCHAR(255) NULL,
    userFlaggedPrice TEXT NULL,
    userFlaggedQuantity TEXT NULL,
    needsFetchReviewReason TEXT NULL,
    pointsNotAwardedReason TEXT NULL,
    pointsPayerId VARCHAR(255) NULL,
    rewardsGroup VARCHAR(255) NULL,
    rewardsProductPartnerId VARCHAR(255) NULL,
    userFlaggedDescription TEXT NULL,
    originalMetaBriteBarcode TEXT NULL,
    originalMetaBriteDescription TEXT NULL,
    brandCode VARCHAR(255) NULL,
    competitorRewardsGroup VARCHAR(255) NULL,
    discountedItemPrice TEXT NULL,
    originalReceiptItemText TEXT NULL,
    itemNumber TEXT NULL,
    originalMetaBriteQuantityPurchased TEXT NULL,
    pointsEarned TEXT NULL,
    targetPrice TEXT NULL,
    competitiveProduct VARCHAR(255) NULL,
    originalFinalPrice TEXT NULL,
    originalMetaBriteItemPrice TEXT NULL,
    deleted VARCHAR(255) NULL,
    priceAfterCoupon TEXT NULL,
    metabriteCampaignId VARCHAR(255) NULL,
    _id VARCHAR(255),
    userId VARCHAR(255) NOT NULL
);
