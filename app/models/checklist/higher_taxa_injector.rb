class Checklist::HigherTaxaInjector
  attr_reader :last_seen_id

  # skip_id can be used to pass the id of last higher taxon added
  # so that the injector does not repeat higher taxa headers across fetches
  # last higher taxon added in this run can be retrieved through last_seen_id
  def initialize(taxon_concepts, options = {})
    @skip_id = options[:skip_id]
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
      prev_item = (i > 0 ? @taxon_concepts[i-1] : nil)
      res += higher_taxa_headers(prev_item, tc).map do |ht|
        Checklist::HigherTaxaItem.new(ht)
      end
      res << tc
    end
    res
  end

  #returns array of HigherTaxaItems that need to be inserted
  #between prev_item and curr_item in the taxonomic layout
  def higher_taxa_headers(prev_item, curr_item)
    ranks = if prev_item.nil?
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
    puts ranks.inspect

    res = []
    ranks.each do |rank|
      higher_taxon_id = curr_item.send("#{rank.downcase}_id")
      @last_seen_id = higher_taxon_id
      unless (prev_item && prev_item.send("#{rank.downcase}_id") == higher_taxon_id && !@expand_headers)
        higher_taxon = @higher_taxa[higher_taxon_id]
        if higher_taxon && higher_taxon.id != @skip_id
          res << higher_taxon
        end
      end
    end
    res
  end

end
