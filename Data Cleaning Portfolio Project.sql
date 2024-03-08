/*

Cleaning Data in SQL Queries

*/
Select *
From PortfolioProject.dbo.NashvilleHousingData

-----------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

Select SaleDateConverted, Convert(date, SaleDate)
From PortfolioProject.dbo.NashvilleHousingData

Update NashvilleHousingData
Set SaleDate=Convert(date, Saledate)

Alter Table PortfolioProject.dbo.NashvilleHousingData
Add SaledateConverted Date;

Update PortfolioProject.dbo.NashvilleHousingData
Set SaleDateConverted=Convert(Date, SaleDate)

 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

Select *
From PortfolioProject.dbo.NashvilleHousingData
--Where PropertyAddress is null
Order By ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
From PortfolioProject.dbo.NashvilleHousingData a
Join PortfolioProject.dbo.NashvilleHousingData b
	on a.ParcelID=b.ParcelID
	And a.[UniqueID]<>b.[UniqueID]
Where a.PropertyAddress is Null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousingData a
JOIN PortfolioProject.dbo.NashvilleHousingData b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null

--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousingData
--Where PropertyAddress is null
--order by ParcelID

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address

From PortfolioProject.dbo.NashvilleHousingData

ALTER TABLE PortfolioProject.dbo.NashvilleHousingData
Add PropertySplitAddress Nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousingData
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE PortfolioProject.dbo.NashvilleHousingData
Add PropertySplitCity Nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousingData
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

Select *
From PortfolioProject.dbo.NashvilleHousingData

Select OwnerAddress
From PortfolioProject.dbo.NashvilleHousingData

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From PortfolioProject.dbo.NashvilleHousingData


ALTER TABLE PortfolioProject.dbo.NashvilleHousingData
Add OwnerSplitAddress Nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousingData
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE PortfolioProject.dbo.NashvilleHousingData
Add OwnerSplitCity Nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousingData
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE PortfolioProject.dbo.NashvilleHousingData
Add OwnerSplitState Nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousingData
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)



Select *
From PortfolioProject.dbo.NashvilleHousingData


--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousingData
Group by SoldAsVacant
order by 2


Select SoldAsVacant
, CASE When Convert(varchar,SoldAsVacant) = '1' THEN 'Yes'
	   When Convert(varchar,SoldAsVacant) = '0' THEN 'No'
	   ELSE Convert(varchar,SoldAsVacant)
	   END
From PortfolioProject.dbo.NashvilleHousingData

Update PortfolioProject.dbo.NashvilleHousingData
SET SoldAsVacant = CASE When Convert(varchar,SoldAsVacant) = 'Y' THEN 'Yes'
	   When Convert(varchar,SoldAsVacant) = 'N' THEN 'No'
	   ELSE Convert(varchar,SoldAsVacant)
	   END


-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

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

From PortfolioProject.dbo.NashvilleHousingData
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
--Order by PropertyAddress



Select *
From PortfolioProject.dbo.NashvilleHousingData

---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns





ALTER TABLE PortfolioProject.dbo.NashvilleHousingData
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
