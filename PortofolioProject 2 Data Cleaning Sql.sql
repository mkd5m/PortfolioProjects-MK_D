/*

Cleaning Data in SQL Queries 
*/

Select * 
From PortfolioProject.dbo.HousingNash


--- Standarize Date Format

Select SaleDateConverted, Convert(Date,SaleDate)
From PortfolioProject.dbo.HousingNash

Update HousingNash
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE HousingNash
Add SaleDateConverted Date;

Update HousingNash
SET SaleDateConverted =CONVERT(Date, SaleDate)

---Populate Property Address Date 

Select *
From PortfolioProject.dbo.HousingNash
--where PropertyAddress is null
order by ParcelID

--- it seems like the ParcelID is the same as PropertyAddress so lets join it


Select m.ParcelID, m.PropertyAddress, k.ParcelID, k.PropertyAddress, ISNULL(m.PropertyAddress,k.PropertyAddress)
From PortfolioProject.dbo.HousingNash m
Join PortfolioProject.dbo.HousingNash k
	on m.ParcelID = k.ParcelID 
	AND m.[UniqueID ] <> k.[UniqueID ]
Where m.PropertyAddress is null 


Update m 
SET PropertyAddress = ISNULL(m.PropertyAddress,k.PropertyAddress)
From PortfolioProject.dbo.HousingNash M
Join PortfolioProject.dbo.HousingNash K
	on m.ParcelID = k.ParcelID 
	AND m.[UniqueID ] <> k.[UniqueID ]
Where m.PropertyAddress is null 


----Breaking Out Address into Individuals Columns(Address, City,State)

Select PropertyAddress
From PortfolioProject.dbo.HousingNash
--where PropertyAddress is null
--order by PropertyAddress

Select
SUBSTRING(PropertyAddress,1, CHARINDEX(',', PropertyAddress)-1 ) as address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+ 1, LEN(PropertyAddress)) as Address

From PortfolioProject.dbo.HousingNash

Alter Table HousingNash
Add PropertySplitAddress Nvarchar(255)

update HousingNash
Set PropertySplitAddress = SUBSTRING(PropertyAddress,1, CHARINDEX(',', PropertyAddress)-1 ) 

Alter Table HousingNash
Add PropertySplitCity Nvarchar(255)

update HousingNash
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+ 1, LEN(PropertyAddress))


Select *
From PortfolioProject.dbo.HousingNash



--Lets do the owner address 

Select OwnerAddress
From PortfolioProject.dbo.HousingNash

Select 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
From PortfolioProject.dbo.HousingNash


Alter Table HousingNash
Add OwnerSplitAddress Nvarchar(255);

Update HousingNash
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

Alter Table HousingNash
add OwnerSplitCity nvarchar(255);

Update HousingNash
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

Alter Table HousingNash
add OwnerSplitState nvarchar(255)

Update HousingNash
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


Select *
From PortfolioProject.dbo.HousingNash


--- The next the step is to change the Y and N in  a Sold as Vacant field.

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject.dbo.HousingNash
Group by SoldAsVacant
order by 2


Select SoldAsVacant
,Case	when SoldAsVacant = 'Y' Then 'Yes'
		when SoldAsVacant = 'N' Then 'No'
		Else SoldAsVacant
		End
From PortfolioProject.dbo.HousingNash


Update HousingNash
Set SoldAsVacant = Case	when SoldAsVacant = 'Y' Then 'Yes'
		when SoldAsVacant = 'N' Then 'No'
		Else SoldAsVacant
		End



---- the Next thing we going to do is Remving the Duplicates 
With RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER(
	PARTITION BY	ParcelID,
					PropertyAddress,
					SalePrice,
					LegalReference
					Order BY
						UniqueID
						) Row_num
FROM PortfolioProject.dbo.HousingNash
--order by ParcelID
)
Select *
From RowNumCTE
where Row_num > 1
order by PropertyAddress






Select *
From PortfolioProject.dbo.HousingNash





--- the Next step is to get ride of the of the unsued colums

Select *
From PortfolioProject.dbo.HousingNash

Alter Table PortfolioProject.dbo.HousingNash
Drop Column OwnerAddress, TaxDistrict,PropertyAddress

Alter Table PortfolioProject.dbo.HousingNash
Drop Column SaleDate

Alter Table PortfolioProject.dbo.HousingNash
Drop Column SaleDateConvrted