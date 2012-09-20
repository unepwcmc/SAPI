SELECT 'Animalia' as Kingdom, C.ComName, L.LanDesc, S.SpcRecID
FROM ORWELL.animals.dbo.Species S 
INNER JOIN ORWELL.animals.dbo.CommonName C on C.ComSpcRecID = S.SpcRecID
INNER JOIN	ORWELL.animals.dbo.Language L ON L.LanRecID = C.ComLanRecID
WHERE L.LanDesc IN ('English', 'Spanish', 'French')
ORDER BY 3;