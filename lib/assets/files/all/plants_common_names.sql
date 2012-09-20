SELECT 'Plantae' as Kingdom, C.ComName, L.LanDesc, S.SpcRecID
FROM ORWELL.plants.dbo.Species S 
INNER JOIN ORWELL.plants.dbo.CommonName C on C.ComSpcRecID = S.SpcRecID
INNER JOIN	ORWELL.plants.dbo.Language L ON L.LanRecID = C.ComLanRecID
WHERE L.LanDesc IN ('English', 'Spanish', 'French')
ORDER BY 3;