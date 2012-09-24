SELECT
'Plantae' AS Kingdom
  ,[DslRecID]
  ,[DslSpcRecID]
  ,[DslDscRecID]
  ,[DslCode]
  ,[DslCodeRecID]
FROM ORWELL.[Plants].[dbo].[DataSourceLink]
WHERE DslSpcRecID IS NOT NULL
