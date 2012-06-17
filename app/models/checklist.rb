class Checklist
  attr_accessor :taxon_concepts_rel
  def initialize(options)
    @taxon_concepts_rel = TaxonConcept.scoped.
      select([:"taxon_concepts.id", :lft, :rgt, :parent_id])
    @designation = options[:designation] || Designation::CITES
    @taxon_concepts_rel = @taxon_concepts_rel.
      joins(:designation).
      where('designations.name' => @designation)
    #limit to the level of listing
    @level_of_listing = options[:level_of_listing] || false
    #TODO
    #filter by geo entities
    @geo_options = []
    @geo_options += options[:country_ids] unless options[:country_ids].nil?
    @geo_options += options[:cites_region_ids] unless options[:cites_region_ids].nil?
    unless @geo_options.empty?
      @taxon_concepts_rel = @taxon_concepts_rel.by_geo_entities(@geo_options)
    end
    #filter by higher taxa
    @higher_taxa = options[:higher_taxon_ids] || nil
    #possible output layouts are:
    #taxonomy (hierarchic, taxonomic order)
    #checklist (flat, alphabetical order)
    @output_layout = options[:output_layout] || :alphabetical
  end

  def generate
    prepare_ancestor_and_descendants_conditions
    return [] unless @ancestor_conditions || @descendant_conditions
    if @output_layout == :taxonomic
      @taxon_concepts = TaxonConcept.
        where([@ancestor_conditions, @descendant_conditions].compact.join(' OR ')).
        where("data -> 'rank_name' <> 'GENUS'").#TODO verify if joining with ranks would be faster
        order("data -> 'taxonomic_position'")
    else
      @taxon_concepts = TaxonConcept.
        where([@ancestor_conditions, @descendant_conditions].compact.join(' OR ')).
        where("data -> 'rank_name' IN (?)", [Rank::GENUS, Rank::SPECIES, Rank::SUBSPECIES]).
        order("data -> 'full_name'")
    end
  end

  private

  def prepare_ancestor_and_descendants_conditions
    ancestor_ranges = []
    descendant_ranges = []
    @taxon_concepts_rel.each do |tc|
      ancestor_ranges << (tc.lft..tc.rgt)
      descendant_ranges << (tc.lft...tc.rgt)
    end
    unless ancestor_ranges.empty?
      ancestor_ranges = Checklist.merge_ranges(ancestor_ranges)
      @ancestor_conditions = ancestor_ranges.map{ |r| "(lft <= #{r.begin} AND rgt >= #{r.end})" }
      @ancestor_conditions = '(' + @ancestor_conditions.join(' OR ') + ')'
    end
    unless descendant_ranges.empty?
      descendant_ranges = Checklist.merge_ranges(descendant_ranges)
      @descendant_conditions = descendant_ranges.map{ |r| "(lft >= #{r.begin} AND lft < #{r.end})" }
      @descendant_conditions = '(' + @descendant_conditions.join(' OR ') + ')'
      @descendant_conditions = [@descendant_conditions, 'inherit_distribution = true'].join(' AND ')
    end
  end

  def self.merge_ranges(ranges)
    ranges = ranges.sort_by {|r| r.first }
    *outages = ranges.shift
    ranges.each do |r|
      lastr = outages[-1]
      if lastr.last >= r.first - 1
        outages[-1] = lastr.first..[r.last, lastr.last].max
      else
        outages.push(r)
      end
    end
    outages
  end


end
