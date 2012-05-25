class Checklist

  def initialize(options)
    @taxon_concepts_rel = TaxonConcept.cites_checklist
    #limit to the level of listing
    @level_of_listing = options[:level_of_listing] || false
    #TODO
    #filter by countries
    @countries = options[:country_ids] || nil
    @taxon_concepts_rel = @taxon_concepts_rel.by_country(@countries) if @countries
    #filter by higher taxa
    @higher_taxa = options[:higher_taxon_ids] || nil
    #TODO
    #possible output layouts are:
    #taxonomy (hierarchic, taxonomic order)
    #checklist (flat, alphabetical order)
    @output_layout = options[:output_layout] || :taxonomy
    #TODO
    @taxon_concepts_rel = @taxon_concepts_rel.order(:lft) unless @countries
  end

  def generate
    ancestor_ranges = []
    descendant_ranges = []
    @taxon_concepts_rel.each do |tc|
      ancestor_ranges << (tc.lft..tc.rgt)
      descendant_ranges << (tc.lft...tc.rgt)
    end
    ancestor_ranges = Checklist.merge_ranges(ancestor_ranges)
    ancestor_conditions = ancestor_ranges.map{ |r| "(lft <= #{r.begin} AND rgt >= #{r.end})" }
    descendant_ranges = Checklist.merge_ranges(descendant_ranges)
    descendant_conditions = descendant_ranges.map{ |r| "(lft >= #{r.begin} AND lft < #{r.end})" }
    TaxonConcept.cites_checklist.
      where((ancestor_conditions.join(' OR ') +
        ' OR ' +
        '((' + descendant_conditions.join(' OR ') + ') AND ' + "inherit_distribution = true)")).
      order('lft')
  end

  private
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