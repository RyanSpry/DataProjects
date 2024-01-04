USE [Test Project 1];

SELECT *
FROM [dbo].[NashvilleHousing];

--Standardize Date Format
SELECT SaleDate,
	   CONVERT(DATE, SaleDate)
FROM [dbo].[NashvilleHousing];

ALTER TABLE NashvilleHousing ADD SaleDateConverted DATE;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(DATE, SaleDate);

--Checking for Nulls by ordering by ParcelID
SELECT *
FROM [dbo].[NashvilleHousing]
ORDER BY ParcelID;

--Self join to see places where address is null, 
--despite having the same parcel ID as another home sale that has an address!
SELECT a.ParcelID
	,a.PropertyAddress
	,b.ParcelID
	,b.PropertyAddress
	,ISNULL(a.PropertyAddress, b.PropertyAddress) AS CorrectAddress
FROM [dbo].[NashvilleHousing] AS a
INNER JOIN [dbo].[NashvilleHousing] AS b ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;

--Update the null addresses!
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [dbo].[NashvilleHousing] AS a
INNER JOIN [dbo].[NashvilleHousing] AS b ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;

--Look at combined address
SELECT PropertyAddress
FROM [dbo].[NashvilleHousing];

--Breaking out Address into Individual Columns (Address, City, State)
SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS Address, --Starting at first value in PropertyAddress then stop at comma
	   SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS City --Starting at end of previous +1 until end of Address
FROM [dbo].[NashvilleHousing];

--Adding separated address columns
ALTER TABLE NashvilleHousing ADD PropertySplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1);

ALTER TABLE NashvilleHousing ADD PropertySplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress));

--Checking for correct format
SELECT PropertySplitAddress,
	   PropertySplitCity
FROM [dbo].[NashvilleHousing];

--Looking at Owner Address
SELECT OwnerAddress
FROM NashvilleHousing;
--Using Parsename instead of substring to break up the address
SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3), 
	   PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2), 
	   PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM NashvilleHousing;

--Create columns to put address parts in to
ALTER TABLE NashvilleHousing ADD OwnerSplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(replace(OwnerAddress, ',', '.'), 3);

ALTER TABLE NashvilleHousing ADD OwnerSplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(replace(OwnerAddress, ',', '.'), 2);

ALTER TABLE NashvilleHousing ADD OwnerSplitState NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(replace(OwnerAddress, ',', '.'), 1);

--Checking format
SELECT OwnerSplitAddress,
	   OwnerSplitCity,
	   OwnerSplitState
FROM NashvilleHousing

--Change Y and N to Yes and No in "Sold as Vacant" field
SELECT SoldAsVacant
FROM NashvilleHousing

--Has some N and Y among all the yes and no
SELECT SoldAsVacant,
	   CASE 
		   WHEN SoldAsVacant = 'Y'
		   THEN 'Yes'
		   WHEN SoldAsVacant = 'N'
		   THEN 'No'
		   ELSE SoldAsVacant
	   END
FROM NashvilleHousing;

UPDATE NashvilleHousing
SET SoldAsVacant = 
	CASE 
		WHEN SoldAsVacant = 'Y'
		THEN 'Yes'
		WHEN SoldAsVacant = 'N'
		THEN 'No'
		ELSE SoldAsVacant
	END;
--Remove Duplicates: usually don't delete from source table
--Use a CTE (temporary table) to delete duplicates
WITH RowNumCTE AS 
	(
	SELECT *,
			ROW_NUMBER() OVER (PARTITION BY ParcelID,
				                            PropertyAddress,
				                            SalePrice,
				                            SaleDate,
				                            LegalReference 
								ORDER BY UniqueID) AS row_num
	FROM NashvilleHousing
	)
DELETE
FROM RowNumCTE
WHERE row_num > 1;

--Delete unused columns
ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress,
	        TaxDistrict,
	        PropertyAddress,
	        SaleDate;

--Look over cleaned table
SELECT *
FROM NashvilleHousing;
