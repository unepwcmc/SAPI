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
            listed_taxa(tex, listed_taxa_ary, kingdom_name)
            listed_taxa_ary = []
          end
          tex << higher_taxon_name(tc)
        else
          listed_taxa_ary << tc
        end
      end
      unless listed_taxa_ary.empty?
        listed_taxa(tex, listed_taxa_ary, kingdom_name)
        listed_taxa_ary = []
      end
      kingdom = fetcher.next
    end while not kingdom.empty?
  end

  def listed_taxa(tex, listed_taxa_ary, kingdom_name='FAUNA')
    tex << "\\listingtable#{kingdom_name.downcase}{"
    rows = []
    listed_taxa_ary.each do |tc|
      listed_taxon_name = listed_taxon_name(tc)
      is_tc_row = true #it is the first row per taxon concept
      tc.listing_changes.each do |lc|
        is_lc_row = true #it is the first row per listing change
        multilingual_annotations(lc).each do |ann|
          row = []
          # tc fields
          row << (is_tc_row ? listed_taxon_name : '')
          is_tc_row = false
          # lc fields
          row << (is_lc_row ? listing_with_change_type(lc) : '')
          row << (is_lc_row && lc.party_name ? lc.party_name.upcase : '')
          row << (is_lc_row ? lc.effective_at_formatted : '')
          if kingdom_name == 'FLORA'
            row << (is_lc_row ? "#{LatexToPdf.escape_latex(lc.symbol)}#{lc.parent_symbol}" : '')
          end
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

  def listing_with_change_type(listing_change)
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

  def common_names_with_lng_initials(taxon_concept)
    res = ''
    unless !@english_common_names || taxon_concept.english_names.empty?
      res += " (E) #{taxon_concept.english_names.join(', ')} "
    end
    unless !@spanish_common_names || taxon_concept.spanish_names.empty?
      res += " (S) #{taxon_concept.spanish_names.join(', ')} "
    end
    unless !@french_common_names || taxon_concept.french_names.empty?
      res += " (E) #{taxon_concept.french_names.join(', ')} "
    end
    res
  end

  def multilingual_annotations(listing_change)
    res = ['english', 'spanish', 'french'].map do |lng|
      if instance_variable_get("@#{lng}_common_names")
        annotation_for_language(listing_change, lng)
      else
        nil
      end
    end.compact
    (res.empty? ? [nil] : res)
  end

  def annotation_for_language(listing_change, lng)
    full_note = listing_change.send("#{lng}_full_note")
    if !full_note.blank?
      full_note = LatexToPdf.escape_latex(
        full_note.force_encoding('UTF-8')
      )
      short_note = listing_change.send("#{lng}_short_note")
      if !short_note.blank?
        short_note = LatexToPdf.escape_latex(
          short_note.force_encoding('UTF-8')
        )
        "\\footnote{#{full_note}} #{short_note}"
      else
        full_note
      end
    else
      nil
    end
  end

  def listed_taxon_name(taxon_concept)
    res = if ['FAMILY','ORDER','CLASS'].include? taxon_concept.rank_name
      taxon_concept.full_name.upcase
    else
      taxon_concept.full_name
    end
    if ['SPECIES', 'SUBSPECIES', 'GENUS'].include? taxon_concept.rank_name
      res = "\\textit{#{res}}"
    end
    res += " #{taxon_concept.spp}" if taxon_concept.spp
    res
  end

  def higher_taxon_name(taxon_concept)
    if taxon_concept.rank_name == 'PHYLUM'
      "\\csection{#{taxon_concept.full_name.upcase}}\n"
    elsif taxon_concept.rank_name == 'CLASS'
      "\\section*{#{taxon_concept.full_name.upcase}}\n"
    elsif ['ORDER','FAMILY'].include? taxon_concept.rank_name
      "\\subsection*{#{taxon_concept.full_name.upcase} #{common_names_with_lng_initials(taxon_concept)}}\n"
    end
  end

end