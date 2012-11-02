module Checklist::Pdf::HistoryContent

  def content(tex)
    fetcher = Checklist::Pdf::HistoryFetcher.new(@animalia_rel)
    kingdom(tex, fetcher, 'FAUNA')
    fetcher = Checklist::Pdf::HistoryFetcher.new(@plantae_rel)
    kingdom(tex, fetcher, 'FLORA')
  end

  def kingdom(tex, fetcher, kingdom_name)
    kingdom = fetcher.next
    return if kingdom.empty?
    tex << "\\cpart{#{kingdom_name}}\n"
    begin
      listed_taxa_ary = []
      kingdom.each do |tc|
        if tc.kind_of? Checklist::HigherTaxaItem
          unless listed_taxa_ary.empty?
            listed_taxa(tex, listed_taxa_ary)
            listed_taxa_ary = []
          end
          higher_taxa(tex, tc)
        else
          listed_taxa_ary << tc
        end
      end
      unless listed_taxa_ary.empty?
        listed_taxa(tex, listed_taxa_ary)
        listed_taxa_ary = []
      end
      kingdom = fetcher.next
    end while not kingdom.empty?
  end

  def higher_taxa(tex, taxon_concept)
    if taxon_concept.rank_name == 'PHYLUM'
      tex << "\\csection{#{taxon_concept.full_name.upcase}}\n"
    elsif taxon_concept.rank_name == 'CLASS'
      tex << "\\section*{#{taxon_concept.full_name.upcase}}\n"
    elsif ['ORDER','FAMILY'].include? taxon_concept.rank_name
      tex << "\\subsection*{#{taxon_concept.full_name.upcase} #{common_names_str(taxon_concept)}}\n"
    end
  end

  def listed_taxa(tex, listed_taxa_ary)
    tex << "\\listingtable{"
    rows = []
    listed_taxa_ary.each do |tc|
      is_tc_row = true #it is the first row per taxon concept
      tc.listing_changes.each do |lc|
        is_lc_row = true #it is the first row per listing change
        multilingual_annotations(lc).each do |ann|
          row = []
          # tc fields
          row << (is_tc_row ? tc.full_name : '')
          is_tc_row = false
          # lc fields
          row << (is_lc_row ? species_listing_str(lc) : '')
          row << (is_lc_row ? lc.effective_at_formatted : '')
          is_lc_row = false
          # ann fields
          row << ann
          rows << row.join(' & ')
        end
      end
    end
    tex << rows.join("\\\\\n")
    tex << "}"
  end

  def species_listing_str(listing_change)
    "#{listing_change.species_listing_name}#{
      if listing_change.change_type_name == ChangeType::RESERVATION
        '/r'
      elsif listing_change.change_type_name == ChangeType::RESERVATION_WITHDRAWAL
        '/w'
      elsif listing_change.change_type_name == ChangeType::DELETION
        'Del'
      else
        nil
      end
    }"
  end

  def common_names_str(taxon_concept)#TODO
    res = ''
    if @english_common_names && !taxon_concept.english_names.empty?
      res << taxon_concept.english_names.join(', ')
    end
    if @spanish_common_names && !taxon_concept.spanish_names.empty?
      res << taxon_concept.spanish_names.join(', ')
    end
    if @french_common_names && !taxon_concept.french_names.empty?
      res << taxon_concept.french_names.join(', ')
    end
    res
  end

  def multilingual_annotations(listing_change)
    ['english', 'spanish', 'french'].map do |lng|
      if instance_variable_get("@#{lng}_common_names")
        full_note = listing_change.send("#{lng}_full_note")
        short_note = listing_change.send("#{lng}_short_note")
        annotation = if full_note && short_note
          "\\footnote{#{full_note}} #{short_note}"
        elsif full_note
          full_note
        end
        LatexToPdf.escape_latex annotation
      else
        nil
      end
    end.compact
  end

end