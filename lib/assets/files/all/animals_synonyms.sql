SELECT 'Animalia' as Kingdom, P.PhyName, C.ClaName, O.OrdName, F.FamName, G.GenName, S.SpcName, S.SpcInfraRank, S.SpcInfraEpithet, S.SpcRecID AS SynonymSpcRecID, S.SpcStatus, SynSpcRecID AS AcceptedSpcRecID
FROM ORWELL.animals.dbo.Species S 
INNER JOIN  ORWELL.animals.dbo.Genus G on S.Spcgenrecid = G.genrecid
INNER JOIN  ORWELL.animals.dbo.Family F ON FamRecID = GenFamRecID
INNER JOIN  ORWELL.animals.dbo.TaxOrder O ON OrdRecID = FamOrdRecID
INNER JOIN  ORWELL.animals.dbo.TaxClass C ON ClaRecID = OrdClaRecID
INNER JOIN  ORWELL.animals.dbo.TaxPhylum P ON PhyRecID = ClaPhyRecID
INNER JOIN  ORWELL.animals.dbo.SynLink Syn ON SynParentRecID = S.SpcRecID
ORDER BY PhyName, ClaName, OrdName, FamName, GenName, SpcName, SpcInfraRank, SpcInfraEpithet