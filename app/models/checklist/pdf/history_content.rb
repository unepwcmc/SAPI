module Checklist::Pdf::HistoryContent

  def content(tex)
    fetcher = Checklist::Pdf::HistoryFetcher.new(@animalia_rel)
    kingdom(tex, fetcher, 'FAUNA')
    fetcher = Checklist::Pdf::HistoryFetcher.new(@plantae_rel)
    kingdom(tex, fetcher, 'FLORA')
  end

  def kingdom(tex, fetcher, kingdom_name)
    @last_seen_id = nil
    kingdom = fetcher.next
    return if kingdom.empty?

    tex << "\\cpart{#{kingdom_name}}\n"
    begin

      injector = Checklist::HigherTaxaInjector.new(
        results,
        {
          :skip_id => @last_seen_id,
          :expand_headers => true#,
          :header_ranks => (kingdom_name == 'FLORA' ? ['FAMILY'] : nil)
        }
      )
      kingdom = injector.run
      @last_seen_id = injector.last_seen_id

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
            row << (is_lc_row ? "#{LatexToPdf.escape_latex(lc.full_hash_ann_symbol)}" : '')
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

  def multilingual_annotations(listing_change)
    res = ['en', 'es', 'fr'].map do |lng|
      annotation_for_language(listing_change, lng)
    end.compact
    (res.empty? ? [nil] : res)
  end

  def annotation_for_language(listing_change, lng)
    short_note = listing_change.send("short_note_#{lng}")
    short_note = LatexToPdf.html2latex(short_note)
    if listing_change.display_in_footnote && lng == 'en'
      full_note = listing_change.send("full_note_#{lng}")
      full_note = LatexToPdf.html2latex(full_note)
      "#{short_note}\\footnote{#{full_note}}"
    else
      short_note
    end
  end

  def listed_taxon_name(taxon_concept)
    res = if ['FAMILY','SUBFAMILY','ORDER','CLASS'].include? taxon_concept.rank_name
      taxon_concept.full_name.upcase
    else
      taxon_concept.full_name
    end
    if ['SPECIES', 'SUBSPECIES', 'GENUS'].include? taxon_concept.rank_name
      res = "\\emph{#{res}}"
    end
    res += " #{taxon_concept.spp}" if taxon_concept.spp
    res
  end

  def higher_taxon_name(taxon_concept)
    common_names = common_names_with_lng_initials(taxon_concept)
    if taxon_concept.rank_name == 'PHYLUM'
      "\\csection{#{taxon_concept.full_name.upcase}}\n"
    elsif taxon_concept.rank_name == 'CLASS'
      "\\section*{\\underline{#{taxon_concept.full_name.upcase}} #{common_names}}\n"
    elsif ['ORDER','FAMILY','SUBFAMILY'].include? taxon_concept.rank_name
      "\\subsection*{#{taxon_concept.full_name.upcase} #{common_names}}\n"
    end
  end

end
