/*
Cleaning Data in SQL Querries

*/

select * from Housing.dbo.Nashville

-- Standartisize Format

ALTER TABLE Nashville     --Create New column
Add SaleDateConverted Date;

   
Update Nashville         --Update new column according to converted column
set SaleDateConverted=convert(date,SaleDate)


-- Populate Property Adress Data

select * from Housing.dbo.Nashville
--where PropertyAddress is null
order by ParcelID


	select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress) --Eðer ayný parcel numarasý olan elemandan birinde adres belirtildiyse adres belirtilen deðer eksik adres yerine konur.
	from Housing.dbo.Nashville a
	join Housing.dbo.Nashville b
	on a.ParcelID=b.ParcelID
	and a.UniqueID <> b.UniqueID
	where a.PropertyAddress is null


Update a
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
	from Housing.dbo.Nashville a
	join Housing.dbo.Nashville b
	on a.ParcelID=b.ParcelID
	and a.UniqueID <> b.UniqueID
	where a.PropertyAddress is null


select * from Housing.dbo.Nashville

--BREAKING ADDRESS INTO COLUMNS

select SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) ADRESS,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) ADRESS2
from Housing.dbo.Nashville



ALTER TABLE Nashville     
Add PropertySplitAddress Nvarchar(255);

   
Update Nashville        
set PropertySplitAddress=SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)


ALTER TABLE Nashville     
Add PropertySplitCity Nvarchar(255);

   
Update Nashville         
set PropertySplitCity=SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))




select PARSENAME(replace(OwnerAddress,',','.'),3),
PARSENAME(replace(OwnerAddress,',','.'),2),
PARSENAME(replace(OwnerAddress,',','.'),1)

from Housing.dbo.Nashville



ALTER TABLE Nashville     
Add OwnerAdressSplit Nvarchar(255);

   
Update Nashville        
set OwnerAdressSplit=PARSENAME(replace(OwnerAddress,',','.'),3)


ALTER TABLE Nashville     
Add OwnerSplitCity Nvarchar(255);

   
Update Nashville         
set OwnerSplitCity=PARSENAME(replace(OwnerAddress,',','.'),2)


ALTER TABLE Nashville     
Add OwnerSplitState Nvarchar(255);

   
Update Nashville         
set OwnerSplitState=PARSENAME(replace(OwnerAddress,',','.'),1)

select * from Housing.dbo.Nashville


--Change Y and N to Yes and No in "Sold as vacant" field

select distinct (SoldAsVacant),count(SoldAsVacant)
from Housing.dbo.Nashville
group by SoldAsVacant



select SoldAsVacant
,case when SoldAsVacant='Y' then 'Yes'
      when SoldAsVacant='N' then 'No'
	  else SoldAsVacant
	  end
from Housing.dbo.Nashville


Update Nashville 
set SoldAsVacant = case when SoldAsVacant='Y' then 'Yes'
      when SoldAsVacant='N' then 'No'
	  else SoldAsVacant
	  end


select distinct(SoldAsVacant),
count(SoldAsVacant) from Housing.dbo.Nashville group by SoldAsVacant


-- Remove Duplicates


select * from Housing.dbo.Nashville 

WITH ROWNUMCTE AS(
select *,
      ROW_NUMBER() OVER(
	  partition by ParcelID,
				   PropertyAddress,
				   SalePrice,
				   SaleDate,
				   LegalReference
				   Order by UniqueID)
				   row_num
from Housing.dbo.Nashville 
--order by UniqueID
)

delete from ROWNUMCTE 
where row_num >1
--order by PropertyAddress

select * from Housing.dbo.Nashville 



--DELETE UNUSED COLUMNS

select * from Housing.dbo.Nashville 


ALTER TABLE Housing.dbo.Nashville
DROP COLUMN OwnerAddress,TaxDistrict,PropertyAddress

ALTER TABLE Housing.dbo.Nashville
DROP COLUMN Saledate