/*
Cleaning Data in SQL Queries
*/
Select *
From Housing_Project.dbo.Nashville_Housing

-- Standardize Date Format
Select SaleDateConverted, Convert(Date,SaleDate)
From Housing_Project.dbo.Nashville_Housing

Update Nashville_Housing
Set SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE Nashville_Housing
ADD SaleDateConverted Date;

UPDATE Nashville_Housing
Set SaleDateConverted = Convert(Date,SaleDate)

--Populate properly Address Data
Select *
From Housing_Project.dbo.Nashville_Housing
--Where PropertyAddress is null
order by ParcelID

Select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
From Housing_Project.dbo.Nashville_Housing a
Join Housing_Project.dbo.Nashville_Housing b
on a.ParcelID=b.ParcelID
And a.[UniqueID ]<>b.[UniqueID ]
Where a.PropertyAddress is null

Update a
Set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From Housing_Project.dbo.Nashville_Housing a
Join Housing_Project.dbo.Nashville_Housing b
on a.ParcelID=b.ParcelID
And a.[UniqueID ]<>b.[UniqueID ]
Where a.PropertyAddress is null

--Breaking out Address into Indiviual columns(Address,city,State)
Select PropertyAddress
From Housing_Project.dbo.Nashville_Housing

Select 
SUBSTRING(PropertyAddress, 1,Charindex(',',PropertyAddress)-1)as Address,
SUBSTRING(PropertyAddress, Charindex(',',PropertyAddress)+1, LEN(PropertyAddress)) as City

From Housing_Project.dbo.Nashville_Housing

ALTER TABLE Nashville_Housing
ADD PropertySplitAddress Nvarchar(255);

UPDATE Nashville_Housing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1,Charindex(',',PropertyAddress)-1)

ALTER TABLE Nashville_Housing
ADD PropertySplitCity Nvarchar(255);

UPDATE Nashville_Housing
Set PropertySplitCity= SUBSTRING(PropertyAddress, Charindex(',',PropertyAddress)+1, LEN(PropertyAddress))

Select *
From Housing_Project.dbo.Nashville_Housing


Select OwnerAddress
From Housing_Project.dbo.Nashville_Housing

Select 
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
From Housing_Project.dbo.Nashville_Housing

ALTER TABLE Nashville_Housing
ADD OwnerSplitAddress Nvarchar(255);

UPDATE Nashville_Housing
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE Nashville_Housing
ADD OwnerSplitCity Nvarchar(255);

UPDATE Nashville_Housing
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE Nashville_Housing
ADD OwnerSplitState Nvarchar(255);

UPDATE Nashville_Housing
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

Select *
From Housing_Project.dbo.Nashville_Housing


--Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From Housing_Project.dbo.Nashville_Housing
Group by SoldAsVacant
order by 2


Select SoldAsVacant,
Case When SoldAsVacant = 'Y' Then 'Yes'
	When SoldAsVacant = 'N' Then 'No'
	Else SoldAsVacant 
	End
	From Housing_Project.dbo.Nashville_Housing


Update Nashville_Housing
Set SoldAsVacant = Case When SoldAsVacant = 'Y' Then 'Yes'
	When SoldAsVacant = 'N' Then 'No'
	Else SoldAsVacant 
	End
	
--Remove Duplicates
WITH RowNumCTE as (
Select *,
	ROW_NUMBER() OVER( 
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				Order by 
					UniqueID
					)row_num

From Housing_Project.dbo.Nashville_Housing
--order by ParcelID
)

--To delete 
--DELETE
--From RowNumCTE
--Where row_num > 1


Select *
From RowNumCTE
Where row_num > 1
order by PropertyAddress

-- Delete Unused Columns

Select *
From Housing_Project.dbo.Nashville_Housing


Alter TABLE Housing_Project.dbo.Nashville_Housing
Drop column OwnerAddress, PropertyAddress

Alter TABLE Housing_Project.dbo.Nashville_Housing
Drop column SaleDate