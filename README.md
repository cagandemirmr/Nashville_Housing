# Nashville Housing Data Cleaning

This project involves cleaning and standardizing the `Housing.dbo.Nashville` dataset using SQL. The primary goals include formatting columns, handling missing data, splitting address fields, converting categorical values, removing duplicates, and dropping unnecessary columns.

## 1. Checking the Data
Initial inspection of the dataset was conducted to identify any non-standardized columns, duplicated rows, and columns that were not practical.

```sql
SELECT * FROM Housing.dbo.Nashville;

```

## 2. Standardizing Date Format
A new column `SaleDateConverted` was added to the table, and the existing `SaleDate` values were converted into a standardized date format.

```sql
ALTER TABLE Nashville
ADD SaleDateConverted Date;

UPDATE Nashville
SET SaleDateConverted = CONVERT(date, SaleDate);

```

## 3. Populating Property Address Data
Null values in the `PropertyAddress` column were handled by joining rows with the same `ParcelID` and updating the null addresses using the `IS` and `NULL`  function.

```sql
SELECT * FROM Housing.dbo.Nashville
ORDER BY ParcelID;

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress,
ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Housing.dbo.Nashville a
JOIN Housing.dbo.Nashville b ON a.ParcelID = b.ParcelID AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL;

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Housing.dbo.Nashville a
JOIN Housing.dbo.Nashville b ON a.ParcelID = b.ParcelID AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL;


```

## 4. Breaking Address into City and State
The `PropertyAddress` column was split into two parts: `PropertySplitAddress` for the address, and `PropertySplitCity` for the city. This was done for easier data handling.

```sql
SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS CityState
FROM Housing.dbo.Nashville;

ALTER TABLE Nashville
ADD PropertySplitAddress NVARCHAR(255);

UPDATE Nashville
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1);

ALTER TABLE Nashville
ADD PropertySplitCity NVARCHAR(255);

UPDATE Nashville
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress));


```


## 5. Parsing Owner Address
The `OwnerAddress` was split into multiple columns: `OwnerAddressSplit`, `OwnerSplitCity`, and `OwnerSplitState` using the `PARSENAME` function to extract parts of the address.

```sql
SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) AS Street,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) AS City,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) AS State
FROM Housing.dbo.Nashville;

ALTER TABLE Nashville
ADD OwnerAddressSplit NVARCHAR(255);

UPDATE Nashville
SET OwnerAddressSplit = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3);

ALTER TABLE Nashville
ADD OwnerSplitCity NVARCHAR(255);

UPDATE Nashville
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2);

ALTER TABLE Nashville
ADD OwnerSplitState NVARCHAR(255);

UPDATE Nashville
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);

```

## 6. Converting Categorical Variables
The categorical variable `SoldAsVacant` had values like `Y`, `N`, `Yes`, and `No`. These were standardized by converting `Y` to `Yes` and `N` to `No` to maintain consistency.

```sql
SELECT DISTINCT (SoldAsVacant), COUNT(SoldAsVacant)
FROM Housing.dbo.Nashville
GROUP BY SoldAsVacant;

SELECT SoldAsVacant,
CASE
    WHEN SoldAsVacant = 'Y' THEN 'Yes'
    WHEN SoldAsVacant = 'N' THEN 'No'
    ELSE SoldAsVacant
END AS ConvertedSoldAsVacant
FROM Housing.dbo.Nashville;

UPDATE Nashville
SET SoldAsVacant = CASE
    WHEN SoldAsVacant = 'Y' THEN 'Yes'
    WHEN SoldAsVacant = 'N' THEN 'No'
    ELSE SoldAsVacant
END;

```

## 7. Removing Duplicate Rows
Duplicate rows in the dataset were removed using the `ROW_NUMBER()` function combined with `PARTITION BY` to ensure that only unique rows remained.

```sql

WITH ROWNUMCTE AS (
    SELECT *,
    ROW_NUMBER() OVER (
        PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
        ORDER BY UniqueID) AS row_num
    FROM Housing.dbo.Nashville
)

DELETE FROM ROWNUMCTE
WHERE row_num > 1;

```

## 8. Dropping Unnecessary Columns
Columns that were no longer needed, such as `OwnerAddress`, `TaxDistrict`, and `PropertyAddress`, were removed from the table to streamline the dataset.

```sql

ALTER TABLE Housing.dbo.Nashville
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate;

```

