Select * 
From PortfolioProject..[dbo.NashvilleHousing]

-- Change SaleDate to Date Format

Select SaleDateConverted
From PortfolioProject..[dbo.NashvilleHousing]

ALTER TABLE [dbo.NashvilleHousing]
Add SaleDateConverted Date; 

Update [dbo.NashvilleHousing]
Set SaleDateConverted = CONVERT(Date, SaleDate)



--Populate Property Address Data where PropertyAddress is NULL

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..[dbo.NashvilleHousing] as a
Join PortfolioProject..[dbo.NashvilleHousing] as b
	on a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..[dbo.NashvilleHousing] as a
Join PortfolioProject..[dbo.NashvilleHousing] as b
	on a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null



-- Breaking out Address into Individual Columns (Address, City, State)
-- Using SUBSTRING

Select PropertyAddress
From PortfolioProject..[dbo.NashvilleHousing]

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, len(PropertyAddress))
From PortfolioProject..[dbo.NashvilleHousing]


ALTER TABLE [dbo.NashvilleHousing]
Add PropertySplitAddress Nvarchar(255); 

Update [dbo.NashvilleHousing]
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE [dbo.NashvilleHousing]
Add PropertySplitCity Nvarchar(255); 

Update [dbo.NashvilleHousing]
Set PropertySplitCity = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)


-- Using PARSENAME

Select PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
From PortfolioProject..[dbo.NashvilleHousing]

ALTER TABLE [dbo.NashvilleHousing]
Add OwnerSplitAddress Nvarchar(255); 

Update [dbo.NashvilleHousing]
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE [dbo.NashvilleHousing]
Add OwnerSplitCity Nvarchar(255); 

Update [dbo.NashvilleHousing]
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE [dbo.NashvilleHousing]
Add OwnerSplitState Nvarchar(255); 

Update [dbo.NashvilleHousing]
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)



-- Change Y and N to Yes and No in "Sold as Vacant" field

Select SoldAsVacant,
 CASE When SoldAsVacant = 'Y' THEN 'YES'
	  When SoldAsVacant = 'N' THEN 'No'
	  Else SoldAsVacant
	  END
From PortfolioProject..[dbo.NashvilleHousing]

Update [dbo.NashvilleHousing]
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'YES'
	  When SoldAsVacant = 'N' THEN 'No'
	  Else SoldAsVacant
	  END



--Remove Duplicates

WITH RowNumCTE AS(
Select *,
ROW_NUMBER() OVER(
PARTITION BY ParcelID,
			 PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 ORDER by UniqueID
			 ) row_num
From PortfolioProject..[dbo.NashvilleHousing]
)

Select *
From RowNumCTE
Where row_num > 1


-- Delete Unused Columns

Select *
From PortfolioProject..[dbo.NashvilleHousing]

ALTER TABLE PortfolioProject..[dbo.NashvilleHousing]
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
