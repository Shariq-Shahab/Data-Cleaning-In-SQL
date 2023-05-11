/*

SQL Queries for Data Cleaning

*/


SELECT * 
FROM Portfolioproject1..NashvilleHousing

-- Standard ize date format
-- Updating Saledate format from datetime to date

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(date,saledate)

SELECT SaleDateConverted
FROM Portfolioproject1..NashvilleHousing

-----------------------------------------------------------------------------------------------------------

--Populate Property Address Data 

SELECT PropertyAddress
FROM Portfolioproject1..NashvilleHousing

-- Finding out the Empty Property Addresses by firstly identifying the same ParcelID and the Property Address 

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID , b.PropertyAddress , ISNULL(a.PropertyAddress,b.PropertyAddress)
From Portfolioproject1..NashvilleHousing a
JOIN Portfolioproject1..NashvilleHousing b
   ON a.ParcelId = b.ParcelId
   and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress IS NULL

-- Then Updating the Empty Addresses From the Findings Above

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From Portfolioproject1..NashvilleHousing a
JOIN Portfolioproject1..NashvilleHousing b
   ON a.ParcelId = b.ParcelId
   and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress IS NULL

-----------------------------------------------------------------------------------------------------------------------------
-- Breaking Address in Indiviual Columns (Address, City ,State)

SELECT 
SUBSTRING(PropertyAddress, 1 , CHARINDEX(',',PropertyAddress) -1) AS Address  --CHARINDEX helps in finding out the exact character we are looking for.
, SUBSTRING(PropertyAddress , CHARINDEX(',',PropertyAddress) +1 , LEN(PropertyAddress)) AS CityAddress -- Breaking Address Into City
FROM Portfolioproject1..NashvilleHousing

-- Altering Column and Updating the Findings of Address in the Current Data Set

ALTER TABLE NashvilleHousing
Add PropertySplitAddress NVARCHAR(255)

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1 , CHARINDEX(',',PropertyAddress) -1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity NVARCHAR(255)

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress , CHARINDEX(',',PropertyAddress) +1 , LEN(PropertyAddress))

SELECT * 
FROM Portfolioproject1..NashvilleHousing

-- Better Way to Split The Columns , Spliting OwnerAddress Column Into Address,City And State

SELECT 
PARSENAME(REPLACE(owneraddress,',','.') , 3) -- PARSENAME Command is also use to seperate the Characters
,PARSENAME(REPLACE(owneraddress,',','.') , 2)
, PARSENAME(REPLACE(owneraddress,',','.') , 1)
FROM Portfolioproject1..NashvilleHousing

-- ALTERING AND UPDATING New Columns Into Dataset

ALTER TABLE NashvilleHousing
Add Ownersplitaddress NVARCHAR(255)

ALTER TABLE NashvilleHousing
Add Ownersplitcity NVARCHAR(255)

ALTER TABLE NashvilleHousing
Add OwnersplitState NVARCHAR(255)

UPDATE NashvilleHousing
SET Ownersplitaddress = PARSENAME(REPLACE(owneraddress,',','.') , 3)

UPDATE NashvilleHousing
SET OwnersplitCity = PARSENAME(REPLACE(owneraddress,',','.') , 2)

UPDATE NashvilleHousing
SET OwnersplitState = PARSENAME(REPLACE(owneraddress,',','.') , 1)

SELECT * 
FROM Portfolioproject1..NashvilleHousing

----------------------------------------------------------------------------------------------------------

-- Change 'Y' and 'N' to 'Yes' and 'No' in SoldasVacant Column

SELECT DISTINCT(SoldAsVacant) , COUNT(SoldAsVacant)
FROM Portfolioproject1..NashvilleHousing
Group by SoldAsVacant
order by 2 desc

SELECT SoldAsVacant
 , CASE WHEN soldasvacant = 'Y' Then 'Yes'
     WHEN soldasvacant = 'N' Then 'No'
	 Else SoldasVacant
	 End 
FROM Portfolioproject1..NashvilleHousing

-- Updating the Changes

Update Portfolioproject1..NashvilleHousing
SET SoldAsVacant = CASE WHEN soldasvacant = 'Y' Then 'Yes'
     WHEN soldasvacant = 'N' Then 'No'
	 Else SoldasVacant
	 End 

-----------------------------------------------------------------------------------------

-- Removing Duplicates by Windows Function
-- Identifying Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From Portfolioproject1.dbo.NashvilleHousing
)
SELECT * -- Delete  ( -- Identifying then Deleting the duplicates)
From RowNumCTE
Where row_num > 1
Order by PropertyAddress


---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns


Select *
From Portfolioproject1.dbo.NashvilleHousing


ALTER TABLE PortfolioProject1.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate