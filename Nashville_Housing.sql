/*
Cleaning Data in SQL Querries

*/

select * from Housing.dbo.Nashville --Checking all datas.According to first scope, i observe non standartisize columns in SaleDate and Sold_as_vacant.Also i observe duplicated rows and non practical columns.

-- STANDARTISIZE FORMAT 

ALTER TABLE Nashville     --Create New column by alter table and Add functions
Add SaleDateConverted Date;

   
Update Nashville         --Update new column by converted column to do so i convert Saledate into date
set SaleDateConverted=convert(date,SaleDate)


-- POPULATE PROPERTY ADRESS DATA 

select * from Housing.dbo.Nashville --Checking null values in PropertyAdress column using is null function in where.
--where PropertyAddress is null
order by ParcelID


	select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress) --I need to apply join to see if there is connection between ParcelID and PropertyAddress
	from Housing.dbo.Nashville a
	join Housing.dbo.Nashville b
	on a.ParcelID=b.ParcelID
	and a.UniqueID <> b.UniqueID
	where a.PropertyAddress is null


Update a
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)  -- According to patttern, i update null valued PropertyAddress Rows by using ISNULL function.
	from Housing.dbo.Nashville a
	join Housing.dbo.Nashville b
	on a.ParcelID=b.ParcelID
	and a.UniqueID <> b.UniqueID
	where a.PropertyAddress is null




--BREAKING ADDRESS INTO COLUMNS   --For practical usage i divide Adress into city and States.

select SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) ADRESS,       -- I use Substring to divide City from Adress.
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) ADRESS2
from Housing.dbo.Nashville



ALTER TABLE Nashville     --Then create column
Add PropertySplitAddress Nvarchar(255);

   
Update Nashville        --And assign values into new column.
set PropertySplitAddress=SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)


ALTER TABLE Nashville     
Add PropertySplitCity Nvarchar(255);

   
Update Nashville         
set PropertySplitCity=SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))




select PARSENAME(replace(OwnerAddress,',','.'),3), --To ease my process,i use ParseName and Replace function instead of substring.
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




--Change Y and N to Yes and No in "Sold as vacant" field --In Sold as Vacant Column, there are 4 variables which are Y,Yes,N and No.To change that i use case when.

select distinct (SoldAsVacant),count(SoldAsVacant)
from Housing.dbo.Nashville
group by SoldAsVacant



select SoldAsVacant
,case when SoldAsVacant='Y' then 'Yes' --If SolasVacan value is 'Y' then it turn into Yes,
      when SoldAsVacant='N' then 'No'  --Else if SolasVacan value is 'N' then it turn into No,
	  else SoldAsVacant            --Otherwise, it will be same
	  end
from Housing.dbo.Nashville


Update Nashville                      --To make changes permenant,i use update command.
set SoldAsVacant = case when SoldAsVacant='Y' then 'Yes'
      when SoldAsVacant='N' then 'No'
	  else SoldAsVacant
	  end


select distinct(SoldAsVacant),
count(SoldAsVacant) from Housing.dbo.Nashville group by SoldAsVacant


-- Remove Duplicates   --I use CMTE and window functions whic are row_number(),over() and partition by functions.


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



--DELETE UNUSED COLUMNS  -- In the end of the process I delete nunnecessary columns.

select * from Housing.dbo.Nashville 


ALTER TABLE Housing.dbo.Nashville
DROP COLUMN OwnerAddress,TaxDistrict,PropertyAddress

ALTER TABLE Housing.dbo.Nashville
DROP COLUMN Saledate
