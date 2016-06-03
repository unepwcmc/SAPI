require Rails.root.join('lib/tasks/elibrary/importable.rb')

class Elibrary::CitationsNoEventImporter < Elibrary::CitationsImporter

  def columns_with_type
    super() + [
      ['ProposalNo', 'TEXT'],
      ['ProposalNature', 'TEXT'],
      ['ProposalOutcome', 'TEXT'],
      ['ProposalAdditionalComments', 'TEXT'],
      ['ProposalHardCopy', 'TEXT'],
      ['ProposalRepresentation', 'TEXT'],
      ['ProposalOtherTaxonName', 'TEXT'],
      ['NDFSource', 'TEXT'],
      ['SigTradePhase', 'TEXT'],
      ['SigTradeProcessStage', 'TEXT'],
      ['SigTradeDocumentNumber', 'TEXT'],
      ['SigTradeIntroduced', 'TEXT'],
      ['SigTradeMeeting1', 'TEXT'],
      ['SigTradeACMeetingDate1', 'TEXT'],
      ['SigTradeMeeting2', 'TEXT'],
      ['SigTradeCommitteeFirstDiscussed', 'TEXT'],
      ['SigTradeSignificantTradeReviewFor', 'TEXT'],
      ['SigTradeRegion1', 'TEXT'],
      ['SigTradeRegion2', 'TEXT'],
      ['SigTradeRegion3', 'TEXT'],
      ['SigTradeURL', 'TEXT'],
      ['SigTradeURL2', 'TEXT'],
      ['SigTradeHardCopyLocation', 'TEXT'],
      ['SigTradeFileName', 'TEXT'],
      ['SigTradePages', 'TEXT'],
      ['SigTradeLanguage', 'TEXT'],
      ['SigTradeIUCNConservationStatus', 'TEXT'],
      ['SigTradeIUCNConservationStatusCriteria', 'TEXT'],
      ['SigTradeAssessorsOfIUCNStatus', 'TEXT'],
      ['SigTradeDateOfIUCNAssessment', 'TEXT'],
      ['SigTradeRecommendedCategory', 'TEXT'],
      ['SigTradeNotes', 'TEXT'],
      ['SigTradeOtherDocumentInformation', 'TEXT'],
      ['SigTradeInitials', 'TEXT'],
      ['SigTradeTaxonID', 'TEXT']
    ]
  end

end
