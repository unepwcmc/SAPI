      SELECT S.SpcRecID as SpcRecID, 'Plantae' as Kingdom, P.PhyName, C.ClaName, O.OrdName, F.FamName, G.GenName, S.SpcName, S.SpcAuthor, S.SpcInfraRank, S.SpcInfraEpithet, SpcInfraRankAuthor, S.SpcStatus
      FROM ORWELL.plants.dbo.Species S
      INNER JOIN ORWELL.plants.dbo.Genus G on G.GenRecID = SpcGenRecID
      INNER JOIN ORWELL.plants.dbo.Family F ON F.FamRecID = GenFamRecID
      INNER JOIN ORWELL.plants.dbo.TaxOrder O ON O.OrdRecID = FamOrdRecID
      LEFT JOIN ORWELL.plants.dbo.TaxClass C ON C.ClaRecID = OrdClaRecID
      LEFT JOIN ORWELL.plants.dbo.TaxPhylum P ON P.PhyRecID = ClaPhyRecID
      WHERE S.SpcStatus = 'A'
      ORDER BY PhyName, ClaName, OrdName, FamName, GenName, SpcName, SpcInfraRank, SpcInfraEpithet