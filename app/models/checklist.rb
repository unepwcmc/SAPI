#Encoding: utf-8
class Checklist
  attr_accessor :taxon_concepts_rel
  def initialize(options)
    @designation = options[:designation] || Designation::CITES

    @taxon_concepts_rel = TaxonConcept.scoped.
      select([:"taxon_concepts.id", :"taxon_concepts.data", :"taxon_concepts.listing", :"taxon_concepts.depth"]).
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
      @taxon_concepts_rel = @taxon_concepts_rel.where("
        data->'rank_name' NOT IN ('SPECIES','SUBSPECIES')
        OR listing->'cites_listing' != ''
        AND listing->'cites_listing' != 'NC'
      ")
    end

    #possible output layouts are:
    #taxonomic (hierarchic, taxonomic order)
    #checklist (flat, alphabetical order)
    @output_layout = options[:output_layout] || :alphabetical
    @taxon_concepts_rel = if @output_layout == :taxonomic
      @taxon_concepts_rel.taxonomic_layout
    else
      @taxon_concepts_rel.alphabetical_layout
    end.order("taxon_concepts.data->'kingdom_name'")#animalia first
    #show synonyms?
    unless options[:synonyms].nil?
      @taxon_concepts_rel = @taxon_concepts_rel.with_synonyms
    end
    #show common names?
    unless options[:common_names].nil?
      @taxon_concepts_rel = @taxon_concepts_rel.with_common_names(options[:common_names])
    end

    #filter by scientific name
    unless options[:scientific_name].nil?
      @taxon_concepts_rel = @taxon_concepts_rel.joins(
        <<-SQL
        INNER JOIN (
          SELECT t, t.id, data->'full_name' AS full_name
          FROM taxon_concepts t
          WHERE data->'full_name' LIKE '%#{options[:scientific_name]}%'
        ) result ON taxon_concepts.data->'full_name' = result.full_name
        SQL
      )
    end
  end

  def generate(page, per_page)
    page ||= 0
    per_page ||= 50
    total_cnt = @taxon_concepts_rel.count
    @taxon_concepts_rel = @taxon_concepts_rel.limit(per_page).offset(per_page.to_i * page.to_i)
    [{
      :taxon_concepts => @taxon_concepts_rel.all,
      :animalia_idx => 0,
      :plantae_idx => @taxon_concepts_rel.
        where("taxon_concepts.data->'kingdom_name' = 'Animalia'").count,
      :result_cnt => @taxon_concepts_rel.count,
      :total_cnt => total_cnt
    }]
  end
end
