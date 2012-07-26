#Encoding: utf-8
class Checklist
  attr_accessor :taxon_concepts_rel, :animalia, :plantae
  def initialize(options)
    @designation = options[:designation] || Designation::CITES

    @taxon_concepts_rel = TaxonConcept.scoped.
      select([:"taxon_concepts.id", :data, :listing, :"taxon_concepts.depth"]).
      joins(:designation).
      where('designations.name' => @designation)

    #filter by geo entities
    @geo_options = []
    @geo_options += options[:country_ids] unless options[:country_ids].nil?
    @geo_options += options[:cites_region_ids] unless options[:cites_region_ids].nil?
    unless @geo_options.empty?
      @taxon_concepts_rel = @taxon_concepts_rel.by_geo_entities(@geo_options)
    end
    #filter by species listing
    unless options[:cites_appendices].nil?
      @taxon_concepts_rel = @taxon_concepts_rel.by_cites_appendices(options[:cites_appendices])
    else
      @taxon_concepts_rel = @taxon_concepts_rel.where("data->'rank_name' NOT IN ('SPECIES','SUBSPECIES') OR listing->'cites_listing' != ''")
    end

    #possible output layouts are:
    #taxonomic (hierarchic, taxonomic order)
    #checklist (flat, alphabetical order)
    @output_layout = options[:output_layout] || :alphabetical
    @taxon_concepts_rel = if @output_layout == :taxonomic
      @taxon_concepts_rel.taxonomic_layout
    else
      @taxon_concepts_rel.alphabetical_layout
    end.order("data->'kingdom_name'")#animalia first
    #include common names?
    @taxon_concepts_rel = @taxon_concepts_rel.with_common_names
  end

  def generate(page, per)
    page ||= 0
    per ||= 50
    @taxon_concepts_rel = @taxon_concepts_rel.limit(per).offset(per * page)
    [{
      :taxon_concepts => @taxon_concepts_rel.all,
      :animalia_idx => 0,
      :plantae_idx => @taxon_concepts_rel.
        where("data->'kingdom_name' = 'Animalia'").count,
      :total_cnt => @taxon_concepts_rel.count
    }]
  end
end
