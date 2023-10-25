--SELECTING DATABASE--
USE [ PortfolioProject];

--QUICK WALK THROUGH DATA--
SELECT * FROM [Nashville Housing]

--POPULATE PROPERTY ADDRESS --

SELECT *
FROM [Nashville Housing]
WHERE PropertyAddress IS NULL
--(NULL VALUES IN PROPERTY ADDRESS COLUMN)

--SELF JOIN

SELECT T1.ParcelID, T1.PropertyAddress, T2.ParcelID, T2.PropertyAddress, ISNULL(T1.PropertyAddress,T2.PropertyAddress)
FROM [Nashville Housing] T1
JOIN [Nashville Housing] T2
ON T1.ParcelID = T2.ParcelID
AND T1.UniqueID != T2.UniqueID
WHERE T1.PropertyAddress IS NULL

UPDATE T1
SET PropertyAddress = ISNULL(T1.PropertyAddress,T2.PropertyAddress)
FROM [Nashville Housing] T1
JOIN [Nashville Housing] T2
ON T1.ParcelID = T2.ParcelID
AND T1.UniqueID != T2.UniqueID
WHERE T1.PropertyAddress IS NULL

--BREAKING PropertyAddress and OwnerAddress into Address and City--

ALTER TABLE [Nashville Housing]
ADD Property_address varchar(max);

ALTER TABLE [Nashville Housing]
ADD Property_city varchar(max);

UPDATE [Nashville Housing]
SET Property_address = SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1)

UPDATE [Nashville Housing]
SET Property_city = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))

ALTER TABLE [Nashville Housing]
ADD Owner_address varchar(max);

ALTER TABLE [Nashville Housing]
ADD Owner_city varchar(max);

ALTER TABLE [Nashville Housing]
ADD Owner_state varchar(max);

UPDATE [Nashville Housing]
SET Owner_address = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

UPDATE [Nashville Housing]
SET Owner_city = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

UPDATE [Nashville Housing]
SET Owner_state = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

--While explorig columns I found out SoldAsVacant column has Y and N in some cells rather than Yes and No--

UPDATE [Nashville Housing]
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
                        WHEN SoldAsVacant = 'N' THEN 'No'
						ELSE SoldAsVacant
						END

--CHECKING IS THERE ANY 'Y' AND 'N' LEFT OR NOT 

SELECT DISTINCT(SoldAsVacant),COUNT(SoldAsVacant)
FROM [Nashville Housing]
GROUP BY SoldAsVacant
ORDER BY COUNT(SoldAsVacant)

--DUPLICATES TREATMENT--

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

From [Nashville Housing]
)
DELETE
From RowNumCTE
Where row_num > 1

--DELETING UNUSED COLUMNS--

ALTER TABLE [Nashville Housing]
DROP COLUMN PropertyAddress,OwnerAddress

SELECT * FROM
[Nashville Housing]