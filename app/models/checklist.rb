class Checklist
  attr_accessor :taxon_concepts_rel
  def initialize(options)
    @taxon_concepts_rel = TaxonConcept.scoped.
      select([:"taxon_concepts.id", :data, :listing, :depth])
    @designation = options[:designation] || Designation::CITES
    @taxon_concepts_rel = @taxon_concepts_rel.
      joins(:designation).
      where('designations.name' => @designation)
    #limit to the level of listing
    @cites_listed = options[:cites_listed] || false
    #TODO
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
    end
    #filter by higher taxa
    @higher_taxa = options[:higher_taxon_ids] || nil
    #possible output layouts are:
    #taxonomic (hierarchic, taxonomic order)
    #checklist (flat, alphabetical order)
    @output_layout = options[:output_layout] || :alphabetical
    #include common names
    #TODO move this somewhere more appropriate
    unless options[:common_names].blank?
      @taxon_concepts_rel = @taxon_concepts_rel.
      select(['E', 'S', 'F'] && options[:common_names].map do |lng|
        "lng_#{lng.downcase}"
      end).
      joins(
        <<-SQL
        INNER JOIN (
          SELECT *
          FROM
          CROSSTAB(
            'SELECT taxon_concepts.id AS taxon_concept_id,
            SUBSTRING(languages.name FROM 1 FOR 1) AS lng,
            ARRAY_AGG(common_names.name) AS common_names_ary 
            FROM "taxon_concepts"
            INNER JOIN "taxon_commons"
              ON "taxon_commons"."taxon_concept_id" = "taxon_concepts"."id" 
            INNER JOIN "common_names"
              ON "common_names"."id" = "taxon_commons"."common_name_id" 
            INNER JOIN "languages"
              ON "languages"."id" = "common_names"."language_id"
            GROUP BY taxon_concepts.id, SUBSTRING(languages.name FROM 1 FOR 1)
            ORDER BY 1,2'
          ) AS ct(
            taxon_concept_id INTEGER,
            lng_E VARCHAR[], lng_F VARCHAR[], lng_S VARCHAR[]
          )
        ) common_names ON taxon_concepts.id = common_names.taxon_concept_id
        SQL
      )
    end
  end

  def generate
    if @output_layout == :taxonomic
      @taxon_concepts = @taxon_concepts_rel.
        where("data -> 'rank_name' <> 'GENUS'").#TODO verify if joining with ranks would be faster
        order("data -> 'taxonomic_position'")
    else
      @taxon_concepts = @taxon_concepts_rel.
        where("data -> 'rank_name' NOT IN (?)", [Rank::CLASS, Rank::PHYLUM, Rank::KINGDOM]).
        order("data -> 'full_name'")
    end
  end

end
