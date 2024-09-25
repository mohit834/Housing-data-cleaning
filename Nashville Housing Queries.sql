-- Cleaning data

Select * 
From [Portfolio project]..NashvilleHousing

--Standaradize Data Format


Select saleDate, convert(Date, saleDate)
From [Portfolio project]..NashvilleHousing

Update [Portfolio project]..NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

Update [Portfolio project]..NashvilleHousing
SET SaleDateConverted = CONVERT(DATE, SaleDate)


--Populate Property Address Data


SELECT *
FROM [Portfolio project]..NashvilleHousing 
--where propertyAddress is null
ORDER BY ParcelID


SELECT a.parcelID, a.propertyAddress, b.parcelID, b.propertyAddress, isNULL(a.propertyAddress, b.PropertyAddress)
FROM [Portfolio project]..NashvilleHousing a
JOIN [Portfolio project]..NashvilleHousing b
	on a.parcelID = b.parcelID 
	AND a.uniqueID <> b.uniqueID
where a.PropertyAddress is NULL


Update a
SET propertyAddress = isNULL(a.propertyAddress, b.PropertyAddress)
FROM [Portfolio project]..NashvilleHousing a
JOIN [Portfolio project]..NashvilleHousing b
	on a.parcelID = b.parcelID 
	AND a.uniqueID <> b.uniqueID
where a.PropertyAddress is NULL


-- Breaking out Address into Individual Columns (Address, City, state)


Select 
SUBSTRING(propertyAddress, 1, CHARINDEX(',', propertyAddress)-1) AS Address
,SUBSTRING(propertyAddress, CHARINDEX(',', propertyAddress) + 1, LEN(propertyAddress)) AS Address
From [Portfolio project]..NashvilleHousing


ALTER TABLE [Portfolio project]..NashvilleHousing
ADD propertySplitAddress Nvarchar(255);

Update [Portfolio project]..NashvilleHousing
SET propertySplitAddress = SUBSTRING(propertyAddress, 1, CHARINDEX(',', propertyAddress)-1)

ALTER TABLE [Portfolio project]..NashvilleHousing
ADD propertySplitCity Nvarchar(255);

Update [Portfolio project]..NashvilleHousing
SET propertySplitCity = SUBSTRING(propertyAddress, CHARINDEX(',', propertyAddress) + 1, LEN(propertyAddress))



SELECT * from [Portfolio project]..NashvilleHousing



SELECT OwnerAddress
from [Portfolio project]..NashvilleHousing


SELECT 
PARSENAME(REPLACE(ownerAddress, ',', '.'), 3),
PARSENAME(REPLACE(ownerAddress, ',', '.'), 2),
PARSENAME(REPLACE(ownerAddress, ',', '.'), 1)
from [Portfolio project]..NashvilleHousing



ALTER TABLE [Portfolio project]..NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

Update [Portfolio project]..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(ownerAddress, ',', '.'), 3)

ALTER TABLE [Portfolio project]..NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);

Update [Portfolio project]..NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(ownerAddress, ',', '.'), 2)

ALTER TABLE [Portfolio project]..NashvilleHousing
ADD OwnerSplitState Nvarchar(255);

Update [Portfolio project]..NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(ownerAddress, ',', '.'), 1)


-- Change Y and N to Yes and No as in Sold as Vacant field
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM [Portfolio project]..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


Select SoldAsVacant, 
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
		 END
FROM [Portfolio project]..NashvilleHousing


UPDATE [Portfolio project]..NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
		 END



--Remove Duplicates
WITH RowNumCTE AS (
SELECT *, 
	ROW_NUMBER() OVER (
	PARTITION BY parcelID, 
				 propertyAddress,
				 SalePrice,
				 SaleDate, 
				 LegalReference
				 ORDER BY uniqueId
				 ) row_num
FROM [Portfolio project]..NashvilleHousing
--ORDER BY parcelId
)
DELETE 
FROM RowNumCTE
WHERE row_num > 1



-- Delete Unused Columns
SELECT * 
FROM [Portfolio project]..NashvilleHousing


ALTER TABLE [Portfolio project]..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress


ALTER TABLE [Portfolio project]..NashvilleHousing
DROP COLUMN SaleDate
