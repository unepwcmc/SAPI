SELECT 
  'Plantae' as Kingdom, S.SpcRecID, L.LegListing, L.LegDateListed, C.CtyRecID, L.LegNotes
FROM ORWELL.plants.dbo.Species AS S
  LEFT JOIN ORWELL.plants.dbo.legal AS L ON S.SpcRecID = L.LegSpcRecID
  LEFT JOIN ORWELL.plants.dbo.legalname AS LN ON L.LegLnmRecID = LN.LnmRecID
  LEFT JOIN ORWELL.plants.dbo.Country as C ON L.LegISO2 = C.CtyISO2
WHERE LN.LnmRecID = 3
ORDER BY S.SpcRecID;