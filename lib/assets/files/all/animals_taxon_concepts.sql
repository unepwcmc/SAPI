      SELECT S.SpcRecID as SpcRecID, 'Animalia' as Kingdom, P.PhyName, C.ClaName, O.OrdName, F.FamName, G.GenName, S.SpcName, S.SpcAuthor, S.SpcInfraRank, S.SpcInfraEpithet, SpcInfraRankAuthor, S.SpcStatus
      FROM ORWELL.animals.dbo.Species S
      INNER JOIN ORWELL.animals.dbo.Genus G on G.GenRecID = SpcGenRecID
      INNER JOIN ORWELL.animals.dbo.Family F ON F.FamRecID = GenFamRecID
      INNER JOIN ORWELL.animals.dbo.TaxOrder O ON O.OrdRecID = FamOrdRecID
      INNER JOIN ORWELL.animals.dbo.TaxClass C ON C.ClaRecID = OrdClaRecID
      INNER JOIN ORWELL.animals.dbo.TaxPhylum P ON P.PhyRecID = ClaPhyRecID
      WHERE S.SpcStatus = 'A'
      ORDER BY PhyName, ClaName, OrdName, FamName, GenName, SpcName, SpcInfraRank, SpcInfraEpithet
