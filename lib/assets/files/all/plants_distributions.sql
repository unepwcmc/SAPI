SELECT 'Plantae' as Kingdom, S.SpcRecID, Cty.CtyRecID, Cty.CtyShort
FROM ORWELL.plants.dbo.Species S 
INNER JOIN ORWELL.plants.dbo.DistribCty Dcty ON S.SpcRecID = Dcty.DCtSpcRecID
INNER JOIN ORWELL.plants.dbo.Country Cty ON Dcty.DCtCtyRecID = Cty.CtyRecID
ORDER BY 1;