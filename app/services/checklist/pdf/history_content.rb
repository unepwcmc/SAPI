module Checklist::Pdf::HistoryContent

  def content(tex)
    fetcher = Checklist::HistoryFetcher.new(@animalia_rel)
    kingdom(tex, fetcher, 'FAUNA')
    fetcher = Checklist::HistoryFetcher.new(@plantae_rel)
    kingdom(tex, fetcher, 'FLORA')
    ak = Checklist::Pdf::HistoryAnnotationsKey.new
    tex << ak.annotations_key
  end

  def kingdom(tex, fetcher, kingdom_name)
    kingdom = fetcher.next
    return if kingdom.empty?
    @skip_ancestor_ids = nil

    tex << "\\cpart{#{kingdom_name}}\n"
    begin

      injector = Checklist::HigherTaxaInjector.new(
        kingdom,
        {
          :skip_ancestor_ids => @skip_ancestor_ids,
          :expand_headers => true,
          :header_ranks => (kingdom_name == 'FLORA' ? ['FAMILY'] : nil)
        }
      )
      kingdom = injector.run
      @skip_ancestor_ids = injector.last_ancestor_ids

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
    end while !kingdom.empty?
  end

  def listed_taxa(tex, listed_taxa_ary, kingdom_name = 'FAUNA')
    tex << "\\listingtable#{kingdom_name.downcase}{"
    rows = []
    listed_taxa_ary.each do |tc|
      listed_taxon_name = listed_taxon_name(tc)
      is_tc_row = true # it is the first row per taxon concept
      tc.historic_cites_listing_changes_for_downloads.each do |lc|
        is_lc_row = true # it is the first row per listing change
        ann = annotation_for_language(lc, I18n.locale)
        row = []
        # tc fields
        row << (is_tc_row ? listed_taxon_name : '')
        is_tc_row = false
        # lc fields
        row << (is_lc_row ? listing_with_change_type(lc) : '')
        row << (is_lc_row && lc.party_iso_code ? lc.party_iso_code.upcase : '')
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
    tex << rows.join("\\\\\n")
    tex << "}"
  end

  def listing_with_change_type(listing_change)
    appendix =
      if listing_change.change_type_name == ChangeType::DELETION
        nil
      else
        listing_change.species_listing_name
      end
    change_type =
      if listing_change.change_type_name == ChangeType::RESERVATION
        '/r'
      elsif listing_change.change_type_name == ChangeType::RESERVATION_WITHDRAWAL
        '/w'
      elsif listing_change.change_type_name == ChangeType::DELETION
        'Del'
      else
        nil
      end
    "#{appendix}#{change_type}"
  end

  def annotation_for_language(listing_change, lng)
    short_note = LatexToPdf.html2latex(
      listing_change.send("short_note_#{lng}")
    )
    nomenclature_note = LatexToPdf.html2latex(
      listing_change.send("nomenclature_note_#{lng}")
    )
    if listing_change.display_in_footnote
      full_note = listing_change.send("full_note_#{lng}")
      full_note && full_note.gsub!(/[\n\r]/, ' ')
      full_note = LatexToPdf.html2latex(full_note)
      "#{short_note}\n\n#{nomenclature_note}\\footnote{#{full_note}}"
    else
      "#{short_note}\n\n#{nomenclature_note}"
    end
  end

  def listed_taxon_name(taxon_concept)
    res =
      if ['FAMILY', 'SUBFAMILY', 'ORDER', 'CLASS'].include? taxon_concept.rank_name
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
    if taxon_concept.rank_name == 'PHYLUM' && taxon_concept.kingdom_name == 'Animalia'
      "\\csection{#{taxon_concept.full_name.upcase}}\n"
    elsif taxon_concept.rank_name == 'CLASS' && taxon_concept.kingdom_name == 'Animalia'
      "\\section*{\\underline{#{taxon_concept.full_name.upcase}} #{common_names}}\n"
    elsif taxon_concept.rank_name == 'ORDER' && taxon_concept.kingdom_name == 'Animalia'
      "\\subsection*{#{taxon_concept.full_name.upcase} #{common_names}}\n"
    elsif ['FAMILY', 'SUBFAMILY'].include? taxon_concept.rank_name
      "\\subsection*{#{taxon_concept.full_name.upcase} #{common_names}}\n"
    end
  end

end
