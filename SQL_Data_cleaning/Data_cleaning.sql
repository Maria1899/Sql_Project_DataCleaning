CREATE DATABASE BD_SALES_HOUSES
GO


/*     Cleaning Data in SQL Queries    */
SELECT * 
FROM [BD_SALES_HOUSES].[dbo].[Housing]


--------------------------------Estandarizar el formato de fecha---------------------------------------------------------------------
SELECT 
	[SALEDATE], 
	CONVERT(DATE, [SALEDATE]) AS FECHA_VENTA
FROM [BD_SALES_HOUSES].[dbo].[Housing];


ALTER TABLE [BD_SALES_HOUSES].[dbo].[Housing]
ADD SaleDateConvert DATE;


UPDATE [BD_SALES_HOUSES].[dbo].[Housing]
SET [SaleDateConvert] = CONVERT(DATE, [SALEDATE])


 -------------------------------Completar los datos de la direccion de propiedad ----------------------------------------------------
SELECT 
	[PROPERTYADDRESS]
FROM [BD_SALES_HOUSES].[dbo].[Housing]
WHERE [PROPERTYADDRESS] IS NULL;


SELECT 
	A.[ParcelID],	
	A.[PropertyAddress], 
	B.[ParcelID], 
	B.[PropertyAddress], 
	ISNULL(A.[PropertyAddress],B.[PropertyAddress])
FROM [BD_SALES_HOUSES].[dbo].[Housing] A
JOIN [BD_SALES_HOUSES].[dbo].[Housing] B
	ON A.[ParcelID] = B.[ParcelID]
	AND A.[UniqueID ] <> B.[UNIQUEID ]
WHERE A.PropertyAddress IS NULL


UPDATE A
SET [PropertyAddress] = ISNULL(A.[PropertyAddress],B.[PropertyAddress])
FROM [BD_SALES_HOUSES].[dbo].[Housing] A
JOIN [BD_SALES_HOUSES].[dbo].[Housing] B
	ON A.[ParcelID] = B.[ParcelID]
	AND A.[UniqueID ] <> B.[UNIQUEID ]
WHERE A.PropertyAddress IS NULL;


----------------------------Dividir la dirección en columnas individuales (dirección, ciudad, estado)----------------------------------

-- PROPERTY ADDRESS: (DIRECCION, CIUDAD)
SELECT [PropertyAddress]
FROM [BD_SALES_HOUSES].[dbo].[Housing]


SELECT 
	SUBSTRING([PropertyAddress], 1, CHARINDEX(',', [PropertyAddress])-1) AS ADDRESS,
	SUBSTRING([PropertyAddress], CHARINDEX(',', [PropertyAddress]) +2, LEN([PropertyAddress])) AS CITY
FROM [BD_SALES_HOUSES].[dbo].[Housing];


ALTER TABLE [BD_SALES_HOUSES].[dbo].[Housing]
ADD [PropertySplitAddress] NVarchar(255);

UPDATE [BD_SALES_HOUSES].[dbo].[Housing]
SET [PropertySplitAddress] = SUBSTRING([PropertyAddress], 1, CHARINDEX(',', [PropertyAddress])-1)



ALTER TABLE [BD_SALES_HOUSES].[dbo].[Housing]
ADD [PropertySplitCity] NVarchar(255);

UPDATE [BD_SALES_HOUSES].[dbo].[Housing]
SET [PropertySplitCity] = SUBSTRING([PropertyAddress], CHARINDEX(',', [PropertyAddress]) +2, LEN([PropertyAddress]))




--OWNER ADDRESS: (DIRECCION, CIUDAD, ESTADO)

SELECT 
	[OWNERADDRESS], [PROPERTYADDRESS]
FROM [BD_SALES_HOUSES].[DBO].[Housing]

SELECT
	PARSENAME(REPLACE([OWNERADDRESS],',','.'),3),
	PARSENAME(REPLACE([OWNERADDRESS],',','.'),2),
	PARSENAME(REPLACE([OWNERADDRESS],',','.'),1)
FROM [BD_SALES_HOUSES].[DBO].[Housing]



ALTER TABLE [BD_SALES_HOUSES].[dbo].[Housing]
ADD [OwnerSplitAddress] NVarchar(255);

UPDATE [BD_SALES_HOUSES].[dbo].[Housing]
SET [OwnerSplitAddress] = PARSENAME(REPLACE([OWNERADDRESS],',','.'),3)


ALTER TABLE [BD_SALES_HOUSES].[dbo].[Housing]
ADD [OwnerSplitCity] NVarchar(255);

UPDATE [BD_SALES_HOUSES].[dbo].[Housing]
SET [OwnerSplitCity] = PARSENAME(REPLACE([OWNERADDRESS],',','.'),2)


ALTER TABLE [BD_SALES_HOUSES].[dbo].[Housing]
ADD [OwnerSplitState] NVarchar(255);

UPDATE [BD_SALES_HOUSES].[dbo].[Housing]
SET [OwnerSplitState] = PARSENAME(REPLACE([OWNERADDRESS],',','.'),1)

--------------------------------Cambie Y y N a Sí y No en el campo "Vendido como vacante"--------------------------------------------

SELECT 
	[SOLDASVACANT], 
	COUNT([SOLDASVACANT]) AS TOTAL
FROM [BD_SALES_HOUSES].[DBO].[Housing]
GROUP BY [SOLDASVACANT];

GO

SELECT 
	[SOLDASVACANT],
	CASE WHEN  [SOLDASVACANT] = 'Y' THEN 'Yes'
		WHEN  [SOLDASVACANT] ='N' THEN 'No'
		ELSE [SOLDASVACANT]
	END
FROM [BD_SALES_HOUSES].[DBO].[Housing]

UPDATE [BD_SALES_HOUSES].[dbo].[Housing]
SET [SOLDASVACANT] = CASE WHEN  [SOLDASVACANT] = 'Y' THEN 'Yes'
						WHEN  [SOLDASVACANT] ='N' THEN 'No'
						ELSE [SOLDASVACANT]
					 END;



--------------------------------------Eliminar duplicados-----------------------------------------------------
WITH RowNumCTE 
AS
(
SELECT * ,
	ROW_NUMBER() OVER (
	PARTITION BY [PARCELID],
				 [PROPERTYADDRESS],
				 [SALEPRICE],
				 [SALEDATE],
				 [LEGALREFERENCE]
				 ORDER BY 
				 [UNIQUEID]
				 ) row_num
FROM [BD_SALES_HOUSES].[DBO].[Housing]
)
DELETE FROM ROWNUMCTE 
WHERE row_num >1


--------------------------------------Eliminar columnas no utilizadas-------------------------------------------------------------------
SELECT * 
FROM [BD_SALES_HOUSES].[DBO].[Housing]


ALTER TABLE [BD_SALES_HOUSES].[DBO].[Housing]
DROP COLUMN [SALEDATE], [OWNERADDRESS], [TAXDISTRICT], [PROPERTYADDRESS]

