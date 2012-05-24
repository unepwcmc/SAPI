class Checklist

  def initialize(options)
    @taxon_concepts_rel = TaxonConcept.cites_checklist
    #limit to the level of listing
    @level_of_listing = options[:level_of_listing] || false
    #TODO
    #filter by countries
    @countries = options[:country_ids] || nil
    @taxon_concepts_rel = @taxon_concepts_rel.by_country(@countries)
    #filter by higher taxa
    @higher_taxa = options[:higher_taxon_ids] || nil
    #TODO
    #possible output layouts are:
    #taxonomy (hierarchic, taxonomic order)
    #checklist (flat, alphabetical order)
    @output_layout = options[:output_layout] || :taxonomy
    #TODO
    @taxon_concepts = []
    @added = {}
  end

  def add(tc)
    unless @added[tc.id]
      @added[tc.id]=true
      @taxon_concepts << tc
    end
  end
  
  def add_ary(tc_ary)
    tc_ary.each{ |tc| add(tc) }
  end

  def generate
    #start with a naive implementation
    res = []
    fetched = {}
    @taxon_concepts_rel.all.each do |tc|
      ancestors = tc.ancestors.cites_checklist
      add_ary ancestors
      add tc
      unless @level_of_listing
        descendants = tc.descendants.cites_checklist
        add_ary descendants
      end
    end
    @taxon_concepts
  end

end