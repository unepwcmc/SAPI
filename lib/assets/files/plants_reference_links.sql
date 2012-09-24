SELECT
'Animalia' AS Kingdom
  ,[DslRecID]
  ,[DslSpcRecID]
  ,[DslDscRecID]
  ,[DslCode]
  ,[DslCodeRecID]
FROM ORWELL.[Animals].[dbo].[DataSourceLink]
WHERE DslSpcRecID IS NOT NULL
