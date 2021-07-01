--CLEANING DATA IN SQL QUERIES
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE DATABASE PortfolioProjects;

select * from PortfolioProjects.dbo.NashvilleHousing;


--STANDARDIZE DATE FORMAT


select SaleDate, convert(date,SaleDate)--removes the time part n leaves only the date part
from PortfolioProjects.dbo.NashvilleHousing;

--update NashvilleHousing
--set SaleDate=convert(date,SaleDate);--if this alone doesn't work, use the query below

alter table nashvillehousing
add SaleDateUpdated date;

update NashvilleHousing
set SaleDateUpdated=convert(date,SaleDate);


-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
--POPULATE PROPERTY ADDRESS DATA

select * from PortfolioProjects.dbo.NashvilleHousing
where PropertyAddress is null;

select * from PortfolioProjects.dbo.NashvilleHousing
order by parcelid;

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProjects.dbo.NashvilleHousing a
join PortfolioProjects.dbo.NashvilleHousing b--self join
on a.ParcelID=b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]--not equal
where a.PropertyAddress is null;

update a
set PropertyAddress= ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProjects.dbo.NashvilleHousing a
join PortfolioProjects.dbo.NashvilleHousing b--self join
on a.ParcelID=b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]--not equal
where a.PropertyAddress is null;

--all null column values updated, check using below


-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
----BREAKING OUT ADDRESS INTO INDIVIDUAL COLUMNS (ADDRESS,CITY,STATE)

select propertyaddress from NashvilleHousing
--in all addresses, the delimiter(or separater) is the comma 

select SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress)) as address
from NashvilleHousing

--add 2 columns to store these 2 substrings

alter table nashvillehousing
add PropertySplitAddress nvarchar(255);

update NashvilleHousing
set PropertySplitAddress=SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1);

alter table nashvillehousing
add PropertySplitCity nvarchar(255);

update NashvilleHousing
set PropertySplitCity=SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress));

select * from NashvilleHousing;



--breaking owner address
select OwnerAddress from NashvilleHousing;

select PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
from NashvilleHousing;


--adding columns n updating values
alter table nashvillehousing
add OwnerSplitAddress nvarchar(255);

update NashvilleHousing
set OwnerSplitAddress=PARSENAME(REPLACE(OwnerAddress,',','.'),3)

alter table nashvillehousing
add OwnerSplitCity nvarchar(255);

update NashvilleHousing
set OwnerSplitCity=PARSENAME(REPLACE(OwnerAddress,',','.'),2)

alter table nashvillehousing
add OwnerSplitState nvarchar(255);

update NashvilleHousing
set OwnerSplitState=PARSENAME(REPLACE(OwnerAddress,',','.'),1)

select * from NashvilleHousing;


-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
--CHANGE Y and N to YES and NO respectively in Sold As Vacant Column

select distinct(SoldAsVacant),count(SoldAsVacant) from NashvilleHousing--gives no. of entries in YES,NO,Y,N
group by SoldAsVacant
order by 2;

select SoldAsVacant,
  CASE WHEN SoldAsVacant='Y' THEN 'Yes'
       WHEN SoldAsVacant='N' THEN 'No'
       ELSE SoldAsVacant
  END
from NashvilleHousing

Update NashvilleHousing
set SoldAsVacant=
CASE WHEN SoldAsVacant='Y' THEN 'Yes'
       WHEN SoldAsVacant='N' THEN 'No'
       ELSE SoldAsVacant
END


-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
--REMOVE DUPLICATES

WITH RowNumCTE AS(
Select *, 
     ROW_NUMBER() OVER(
     PARTITION BY ParcelID,
	              PropertyAddress,
				  SalePrice,
				  SaleDate,
				  LegalReference
		          order by 
				  UniqueID
				  ) row_num
from NashvilleHousing
)

Select * from RowNumCTE
where row_num>1
order by PropertyAddress; 


-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
--DELETE UNUSED COLUMNS

select * from NashvilleHousing;

alter table NashvilleHousing
drop column SaleDate,OwnerAddress,PropertyAddress,TaxDistrict;
