SELECT *
FROM Portfolio_Project.dbo.Nashville_Housing

-- Standardize Date format

Select SaleDate, Convert(Date,SaleDate)
From Portfolio_Project.dbo.Nashville_Housing

Update Portfolio_Project.dbo.Nashville_Housing
Set SaleDate = Convert(Date,SaleDate)

--check 

Select SaleDateConverted
From Portfolio_Project.dbo.Nashville_Housing

--doesn't work - attempt II

ALTER TABLE Nashville_Housing
Add SaleDateConverted Date

Update Portfolio_Project.dbo.Nashville_Housing
SET SaleDateConverted = Convert(Date, SaleDate)


-- Populate Property Address data


Select *
From Portfolio_Project.dbo.Nashville_Housing
--Where PropertyAddress IS NULL
Order by ParcelID

-- I attempt

Select nh1.ParcelID, nh1.PropertyAddress, nh2.PropertyAddress
From  Portfolio_Project.dbo.Nashville_Housing nh1
	LEFT Join Portfolio_Project.dbo.Nashville_Housing nh2 
	ON nh1.ParcelID=nh2.ParcelID
		Where nh1.PropertyAddress IS NULL AND nh2.PropertyAddress IS NOT NULL

-- II attempt

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL (a.propertyaddress, b.PropertyAddress)
from Portfolio_Project.dbo.Nashville_Housing a 
	Join Portfolio_Project.dbo.Nashville_Housing b
	On a.ParcelID=b.ParcelID
		AND a.[UniqueID ]<>b.[UniqueID ]
	Where a.PropertyAddress IS NULL

-- replacing NULL's

Update a
SET PropertyAddress = ISNULL (a.propertyaddress, b.PropertyAddress)
from Portfolio_Project.dbo.Nashville_Housing a 
	Join Portfolio_Project.dbo.Nashville_Housing b
	On a.ParcelID=b.ParcelID
		AND a.[UniqueID ]<>b.[UniqueID ]
	Where a.PropertyAddress IS NULL

-- Breaking out Address into individual columns (address, city, state)

Select PropertyAddress
From Portfolio_Project.dbo.Nashville_Housing
--Where PropertyAddress IS NULL
--Order by ParcelID

-- 2 chunks: first - before coma, second - after coma

Select 
	substring (PropertyAddress, 1, charindex(',', PropertyAddress)-1) as Address, 
	substring (PropertyAddress, charindex(',', PropertyAddress)+1, LEN(PropertyAddress)) as Address
From Portfolio_Project.dbo.Nashville_Housing

-- Adding columns for:
--Address
use Portfolio_Project

Alter Table Nashville_Housing
Add PropertySplitAddress Nvarchar(255)

Update Portfolio_Project.dbo.Nashville_Housing
SET PropertySplitAddress = substring(PropertyAddress, 1, charindex(',', PropertyAddress)-1)

--City

Alter Table Nashville_Housing
Add PropertySplitCity Nvarchar(255)

Update Portfolio_Project.dbo.Nashville_Housing
SET PropertySplitCity = substring (PropertyAddress, charindex(',', PropertyAddress)+1, LEN(PropertyAddress))

--same comes to the OwnerAddress though with other functions

Select OwnerAddress
from Portfolio_Project.dbo.Nashville_Housing

Select Parsename(Replace(ownerAddress, ',', '.'), 3),
Parsename(Replace(ownerAddress, ',', '.'), 2),
Parsename(Replace(ownerAddress, ',', '.'), 1)
From Portfolio_Project.dbo.Nashville_Housing

Alter Table Nashville_Housing
Add OwnerSplitAddress Nvarchar(255)

Update Portfolio_Project.dbo.Nashville_Housing
SET OwnerSplitAddress = Parsename(Replace(ownerAddress, ',', '.'), 3)

--City

Alter Table Nashville_Housing
Add OwnerSplitCity Nvarchar(255)

Update Portfolio_Project.dbo.Nashville_Housing
SET OwnerSplitCity = Parsename(Replace(ownerAddress, ',', '.'), 2)

--State

Alter Table Nashville_Housing
Add OwnerSplitState Nvarchar(255)

Update Portfolio_Project.dbo.Nashville_Housing
SET OwnerSplitState = Parsename(Replace(ownerAddress, ',', '.'), 1)

Select Distinct SoldAsVacant
From Portfolio_Project.dbo.Nashville_Housing


Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' then 'Yes'
When SoldAsVacant = 'N' then 'No'
Else SoldAsVacant
END
From Portfolio_Project.dbo.Nashville_Housing

Update Nashville_Housing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' then 'Yes'
When SoldAsVacant = 'N' then 'No'
Else SoldAsVacant
END
From Portfolio_Project.dbo.Nashville_Housing

-- Remove duplicates

WITH RowNumCTE AS (
Select *,
Row_number() OVER ( PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference ORDER BY UniqueID) row_num 
From Portfolio_Project.dbo.Nashville_Housing
--Order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order By PropertyAddress

-- Change 'Select' to 'Delete'

WITH RowNumCTE AS (
Select *,
Row_number() OVER ( PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference ORDER BY UniqueID) row_num 
From Portfolio_Project.dbo.Nashville_Housing
--Order by ParcelID
)
DELETE
From RowNumCTE
Where row_num > 1

-- Delete Unused Columns

Alter Table Portfolio_Project.dbo.Nashville_Housing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

Alter Table Portfolio_Project.dbo.Nashville_Housing
Drop Column SaleDate