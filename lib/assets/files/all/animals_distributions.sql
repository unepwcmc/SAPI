SELECT 'Animalia' as Kingdom, S.SpcRecID, Cty.CtyRecID, Cty.CtyShort
FROM ORWELL.animals.dbo.Species S 
INNER JOIN ORWELL.animals.dbo.DistribCty Dcty ON S.SpcRecID = Dcty.DCtSpcRecID
INNER JOIN ORWELL.animals.dbo.Country Cty ON Dcty.DCtCtyRecID = Cty.CtyRecID
ORDER BY 1;