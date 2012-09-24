SELECT 'Plantae' as Kingdom , P.PhyName, C.ClaName, O.OrdName, F.FamName, G.GenName, S.SpcName, S.SpcAuthor, S.SpcInfraRank, S.SpcInfraEpithet, SpcInfraRankAuthor, S.SpcRecID AS SynonymSpcRecID, S.SpcStatus, SynSpcRecID AS AcceptedSpcRecID
FROM ORWELL.plants.dbo.Species S 
INNER JOIN  ORWELL.plants.dbo.Genus G on S.Spcgenrecid = G.genrecid
INNER JOIN  ORWELL.plants.dbo.Family F ON FamRecID = GenFamRecID
INNER JOIN  ORWELL.plants.dbo.TaxOrder O ON OrdRecID = FamOrdRecID
LEFT JOIN  ORWELL.plants.dbo.TaxClass C ON ClaRecID = OrdClaRecID
LEFT JOIN  ORWELL.plants.dbo.TaxPhylum P ON PhyRecID = ClaPhyRecID
INNER JOIN  ORWELL.plants.dbo.SynLink Syn ON SynParentRecID = S.SpcRecID
ORDER BY PhyName, ClaName, OrdName, FamName, GenName, SpcName, SpcInfraRank, SpcInfraEpithet