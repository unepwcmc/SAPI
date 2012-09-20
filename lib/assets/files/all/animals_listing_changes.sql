SELECT 
  'Animalia' as Kingdom, S.SpcRecID, L.LegListing, L.LegDateListed, C.CtyRecID, L.LegNotes
FROM ORWELL.animals.dbo.Species AS S
  LEFT JOIN ORWELL.animals.dbo.legal AS L ON S.SpcRecID = L.LegSpcRecID
  LEFT JOIN ORWELL.animals.dbo.legalname AS LN ON L.LegLnmRecID = LN.LnmRecID
  LEFT JOIN ORWELL.animals.dbo.Country as C ON L.LegISO2 = C.CtyISO2
WHERE LN.LnmRecID = 3
ORDER BY S.SpcRecID;