class Checklist::HigherTaxaInjector
  attr_reader :last_ancestor_ids

  # skip_ancestor_ids can be used to pass the array of ids of last higher taxa added
  # e.g. if the headers for chordata -> mammalia -> antilocapridae have already been
  # returned, you only want bovidae for the next family, so to suppress outputting
  # chordata -> mammalia pass their ids in an array
  # of course all that only makes sense when your fetching taxon concepts in batches
  # but the final output needs to be continuous
  # last higher taxa added in this run can be retrieved through last_ancestors_ids
  def initialize(taxon_concepts, options = {})
    @skip_ancestor_ids = options[:skip_ancestor_ids]
    @expand_headers = options[:expand_headers] || false
    @ranks = ['PHYLUM', 'CLASS', 'ORDER', 'FAMILY', 'SUBFAMILY', 'GENUS', 'SPECIES']
    @header_ranks = options[:header_ranks] || ['PHYLUM', 'CLASS', 'ORDER', 'FAMILY']
    @taxon_concepts = taxon_concepts
    # fetch all higher taxa first
    higher_taxa_ids = @taxon_concepts.map do |tc|
      [tc.phylum_id, tc.class_id, tc.order_id, tc.family_id]
    end.flatten.uniq
    @higher_taxa = Hash[
      MTaxonConcept.where(:id => higher_taxa_ids).map { |tc| [tc.id, tc] }
    ]
  end

  def run
    res = []
    @taxon_concepts.each_with_index do |tc, i|
      prev_item = (i > 0 ? @taxon_concepts[i - 1] : nil)
      res += higher_taxa_headers(prev_item, tc).map do |ht|
        Checklist::HigherTaxaItem.new(ht)
      end
      res << tc
    end
    res
  end

  def run_summary
    @expand_headers = false # use this only for collapsed headers
    # such as the Checklist or Species+ website
    res = []
    current_higher_taxon = nil
    current_higher_taxon_children_ids = []
    @taxon_concepts.each_with_index do |tc, i|
      prev_item = (i > 0 ? @taxon_concepts[i - 1] : nil)
      higher_taxon = higher_taxa_headers(prev_item, tc).first
      if higher_taxon
        res.push({
          :higher_taxon => Checklist::HigherTaxaItem.new(current_higher_taxon),
          :taxon_concept_ids => current_higher_taxon_children_ids
        }) unless current_higher_taxon.nil?
        current_higher_taxon = higher_taxon
        current_higher_taxon_children_ids = []
      end
      current_higher_taxon_children_ids << tc.id
    end
    # push the last one
    res.push({
      :higher_taxon => Checklist::HigherTaxaItem.new(current_higher_taxon),
      :taxon_concept_ids => current_higher_taxon_children_ids
    }) unless current_higher_taxon.nil?
    res
  end

  # returns array of HigherTaxaItems that need to be inserted
  # between prev_item and curr_item in the taxonomic layout
  def higher_taxa_headers(prev_item, curr_item)
    ranks =
      if prev_item.nil?
        @header_ranks
      else
        tmp = []

        for rank in @header_ranks.reverse
          rank_id_attr = "#{rank.downcase}_id"
          curr_item.send(rank_id_attr)
          if prev_item.send(rank_id_attr) != curr_item.send(rank_id_attr)
            tmp << rank
          else
            break
          end
        end
        tmp.reverse
      end

    ranks = [ranks.last].compact unless @expand_headers

    res = []
    @last_ancestor_ids = @header_ranks.map { |rank| curr_item.send("#{rank.downcase}_id") }
    ranks.each_with_index do |rank, idx|
      higher_taxon_id = curr_item.send("#{rank.downcase}_id")

      unless (prev_item && prev_item.send("#{rank.downcase}_id") == higher_taxon_id && !@expand_headers)
        higher_taxon = @higher_taxa[higher_taxon_id]
        if higher_taxon && !(@skip_ancestor_ids && @skip_ancestor_ids.include?(higher_taxon.id))
          res << higher_taxon
        end
      end
    end
    res
  end

end
