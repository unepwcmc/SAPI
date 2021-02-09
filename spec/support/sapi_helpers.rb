shared_context :sapi do

  def cites_eu
    @_cites_eu ||= create(:taxonomy, :name => Taxonomy::CITES_EU)
  end

  def cms
    @_cms ||= create(:taxonomy, :name => Taxonomy::CMS)
  end

  def cites
    return @_cites if @_cites
    d = Designation.find_by_taxonomy_id_and_name(cites_eu.id, Designation::CITES)
    unless d
      d = create(:designation, :name => Designation::CITES, :taxonomy => cites_eu)
      %w(ADDITION DELETION RESERVATION RESERVATION_WITHDRAWAL EXCEPTION).each do |ch|
        ch_type = ChangeType.find_by_designation_id_and_name(d.id, ch)
        unless ch_type
          create(:change_type, :name => ch, :designation => d)
        end
        %w(I II III).each do |app|
          unless SpeciesListing.find_by_designation_id_and_abbreviation(d.id, app)
            create(
              :species_listing, :name => "Appendix #{app}", :abbreviation => app,
              :designation => d
            )
          end
        end
      end
    end
    @_cites = d
  end

  def eu
    return @_eu if @_eu
    d = Designation.find_by_taxonomy_id_and_name(cites_eu.id, Designation::EU)
    unless d
      d = create(:designation, :name => Designation::EU, :taxonomy => cites_eu)
      %w(ADDITION DELETION RESERVATION RESERVATION_WITHDRAWAL EXCEPTION).each do |ch|
        unless ChangeType.find_by_designation_id_and_name(d.id, ch)
          create(:change_type, :name => ch, :designation => d)
        end
        %w(A B C D).each do |app|
          unless SpeciesListing.find_by_designation_id_and_abbreviation(d.id, app)
            create(
              :species_listing, :name => "Annex #{app}", :abbreviation => app,
              :designation => d
            )
          end
        end
      end
    end
    @_eu ||= d
  end

  def cms_designation
    return @_cms_designation if @_cms_designation
    d = Designation.find_by_taxonomy_id_and_name(cms.id, Designation::CMS)
    unless d
      d = create(:designation, :name => Designation::CMS, :taxonomy => cms)
      %w(ADDITION DELETION EXCEPTION).each do |ch|
        unless ChangeType.find_by_designation_id_and_name(d.id, ch)
          create(:change_type, :name => ch, :designation => d)
        end
        %w(I II).each do |app|
          unless SpeciesListing.find_by_designation_id_and_abbreviation(d.id, app)
            create(
              :species_listing, :name => "Appendix #{app}", :abbreviation => app,
              :designation => d
            )
          end
        end
      end
    end
    @_cms_designation = d
  end

  %w(ADDITION DELETION RESERVATION RESERVATION_WITHDRAWAL EXCEPTION).each do |ch|

    define_method "cites_#{ch.downcase}" do
      ChangeType.find_by_designation_id_and_name(cites.id, ch)
    end

    define_method "eu_#{ch.downcase}" do
      ChangeType.find_by_designation_id_and_name(eu.id, ch)
    end

    %w(I II III).each do |app|
      define_method "cites_#{app}" do
        SpeciesListing.find_by_designation_id_and_abbreviation(cites.id, app)
      end
      define_method "create_cites_#{app}_#{ch.downcase}" do |options = {}|
        create(
          :listing_change,
          options.merge({
            :change_type => send(:"cites_#{ch.downcase}"),
            :species_listing => send(:"cites_#{app}")
          })
        )
      end
    end
    %w(A B C D).each do |app|
      define_method "eu_#{app}" do
        SpeciesListing.find_by_designation_id_and_abbreviation(eu.id, app)
      end
      define_method "create_eu_#{app}_#{ch.downcase}" do |options = {}|
        create(
          :listing_change,
          options.merge({
            :change_type => send(:"eu_#{ch.downcase}"),
            :species_listing => send(:"eu_#{app}")
          })
        )
      end
    end
  end

  %w(ADDITION DELETION EXCEPTION).each do |ch|

    define_method "cms_#{ch.downcase}" do
      ChangeType.find_by_designation_id_and_name(cms_designation.id, ch)
    end

    %w(I II).each do |app|
      define_method "cms_#{app}" do
        SpeciesListing.find_by_designation_id_and_abbreviation(cms_designation.id, app)
      end
      define_method "create_cms_#{app}_#{ch.downcase}" do |options = {}|
        create(
          :listing_change,
          options.merge({
            :change_type => send(:"cms_#{ch.downcase}"),
            :species_listing => send(:"cms_#{app}")
          })
        )
      end
    end
  end

  def cms_animalia
    @_cms_animalia ||=
      create_cms_kingdom(
        :taxonomic_position => '1',
        :taxon_name => create(:taxon_name, :scientific_name => 'Animalia')
      )
  end
  def cms_chordata
    @_cms_chordata ||=
      create_cms_phylum(
        :taxonomic_position => '1.1',
        :taxon_name => create(:taxon_name, :scientific_name => 'Chordata'),
        :parent => cms_animalia
      )
  end
  def cites_eu_mammalia
    @_cites_eu_mammalia ||= create_cites_eu_class(
      :taxonomic_position => '1.1.1',
      :taxon_name => create(:taxon_name, :scientific_name => 'Mammalia'),
      :parent => cites_eu_chordata
    )
  end
  def cms_mammalia
    @_cms_mammalia ||=
      create_cms_class(
        :taxonomic_position => '1.1.1',
        :taxon_name => create(:taxon_name, :scientific_name => 'Mammalia'),
        :parent => cms_chordata
      )
  end
  def cites_eu_aves
    @_cites_eu_aves ||=
      create_cites_eu_class(
        :taxonomic_position => '1.1.2',
        :taxon_name => create(:taxon_name, :scientific_name => 'Aves'),
        :parent => cites_eu_chordata
      )
  end
  def cms_reptilia
    @_cms_reptilia ||=
      create_cms_class(
        :taxonomic_position => '1.1.3',
        :taxon_name => create(:taxon_name, :scientific_name => 'Reptilia'),
        :parent => cms_chordata
      )
  end
  def cites_eu_amphibia
    @_cites_eu_amphibia ||=
      create_cites_eu_class(
        :taxonomic_position => '1.1.4',
        :taxon_name => create(:taxon_name, :scientific_name => 'Amphibia'),
        :parent => cites_eu_chordata
      )
  end
  def cites_eu_elasmobranchii
    @_cites_eu_elasmobranchii ||=
      create_cites_eu_class(
        :taxonomic_position => '1.1.5',
        :taxon_name => create(:taxon_name, :scientific_name => 'Elasmobranchii'),
        :parent => cites_eu_chordata
      )
  end
  def cites_eu_arthropoda
    @_cites_eu_arthropoda ||=
      create_cites_eu_phylum(
        :taxonomic_position => '1.3',
        :taxon_name => create(:taxon_name, :scientific_name => 'Arthropoda'),
        :parent => cites_eu_animalia
      )
  end
  def cites_eu_insecta
    @_cites_eu_insecta ||=
      create_cites_eu_class(
        :taxonomic_position => '1.3.2',
        :taxon_name => create(:taxon_name, :scientific_name => 'Insecta'),
        :parent => cites_eu_arthropoda
      )
  end
  def cites_eu_annelida
    @_cites_eu_annelida ||=
      create_cites_eu_phylum(
        :taxonomic_position => '1.4',
        :taxon_name => create(:taxon_name, :scientific_name => 'Annelida'),
        :parent => cites_eu_animalia
      )
  end
  def cites_eu_hirudinoidea
    @_cites_eu_hirudinoidea ||=
      create_cites_eu_class(
        :taxonomic_position => '1.4.1',
        :taxon_name => create(:taxon_name, :scientific_name => 'Hirudinoidea'),
        :parent => cites_eu_annelida
      )
  end
  def cites_eu_plantae
    @_cites_eu_plantae ||=
      create_cites_eu_kingdom(
        :taxonomic_position => '2',
        :taxon_name => create(:taxon_name, :scientific_name => 'Plantae')
      )
  end

  def cites_eu_animalia
    @_cites_eu_animalia ||= create_cites_eu_kingdom(
      :taxonomic_position => '1',
      :taxon_name => create(:taxon_name, :scientific_name => 'Animalia')
    )
  end

  def cites_eu_chordata
    @_cites_eu_chordata ||= create_cites_eu_phylum(
      :taxonomic_position => '1.1',
      :taxon_name => create(:taxon_name, :scientific_name => 'Chordata'),
      :parent => cites_eu_animalia
    )
  end

  def cites_eu_reptilia
    @_cites_eu_reptilia ||= create_cites_eu_class(
      :taxonomic_position => '1.1.3',
      :taxon_name => create(:taxon_name, :scientific_name => 'Reptilia'),
      :parent => cites_eu_chordata
    )
  end

  def create_cites_eu_animal_species(options = {})
    create_cites_eu_species(
      parent: create_cites_eu_genus(
        parent: create_cites_eu_family(
          parent: create_cites_eu_order(options.merge({ parent: cites_eu_mammalia }))
        )
      )
    )
  end

  def create_cites_eu_plant_species(options = {})
    create_cites_eu_species(
      parent: create_cites_eu_genus(
        parent: create_cites_eu_family(
          parent: create_cites_eu_order(options.merge({ parent: cites_eu_plantae }))
        )
      )
    )
  end

  %w(KINGDOM PHYLUM CLASS ORDER FAMILY SUBFAMILY GENUS SPECIES SUBSPECIES VARIETY).each do |rank|
    define_method "create_#{rank.downcase}" do |options = {}|
      create(
        :taxon_concept,
        options.merge({ rank: create(:rank, name: rank) })
      )
    end
    define_method "build_#{rank.downcase}" do |options = {}|
      build(
        :taxon_concept,
        options.merge({ rank: create(:rank, name: rank) })
      )
    end
    define_method "create_cites_eu_#{rank.downcase}" do |options = {}|
      create(
        :taxon_concept,
        options.merge({
          rank: create(:rank, name: rank),
          taxonomy: cites_eu
        })
      )
    end
    define_method "build_cites_eu_#{rank.downcase}" do |options = {}|
      build(
        :taxon_concept,
        options.merge({
          rank: create(:rank, name: rank),
          taxonomy: cites_eu
        })
      )
    end
    define_method "create_cms_#{rank.downcase}" do |options = {}|
      create(
        :taxon_concept,
        options.merge({
          rank: create(:rank, name: rank),
          taxonomy: cms
        })
      )
    end
    define_method "build_cms_#{rank.downcase}" do |options = {}|
      build(
        :taxon_concept,
        options.merge({
          rank: create(:rank, name: rank),
          taxonomy: cms
        })
      )
    end
  end

  [:cites_cop, :cites_ac, :cites_pc, :cites_tc, :cites_extraordinary_meeting,
    :cites_suspension_notification].each do |cites_event_type|
    define_method "create_#{cites_event_type}" do |options = {}|
      create(
        cites_event_type,
        options.merge({ :designation => cites })
      )
    end
    define_method "build_#{cites_event_type}" do |options = {}|
      build(
        cites_event_type,
        options.merge({ :designation => cites })
      )
    end
  end
  [:eu_regulation, :eu_suspension_regulation, :eu_implementing_regulation,
    :eu_council_regulation, :ec_srg].each do |eu_event_type|
    define_method "create_#{eu_event_type}" do |options = {}|
      create(
        eu_event_type,
        options.merge({ :designation => eu })
      )
    end
    define_method "build_#{eu_event_type}" do |options = {}|
      build(
        eu_event_type,
        options.merge({ :designation => eu })
      )
    end
  end

  def create_taxon_name_presence_validation
    create(
      :presence_validation_rule,
      :column_names => ['taxon_name']
    )
  end

  def create_year_format_validation
    create(
      :format_validation_rule,
      :column_names => ['year'],
      :format_re => '^\d{4}$',
      :is_strict => true
    )
  end

  def create_taxon_concept_validation
    create(
      :inclusion_validation_rule,
      column_names: ['taxon_name'],
      valid_values_view: 'valid_taxon_name_view',
      is_strict: true
    )
  end

  def create_taxon_concept_appendix_year_validation
    create(:taxon_concept_appendix_year_validation_rule,
      :is_primary => false,
      :is_strict => true
    )
  end

  def create_term_unit_validation
    create(:inclusion_validation_rule,
      :column_names => ['term_code', 'unit_code'],
      :valid_values_view => 'valid_term_unit_view',
      :is_primary => false
    )
  end

  def create_term_purpose_validation
    create(:inclusion_validation_rule,
      :column_names => ['term_code', 'purpose_code'],
      :valid_values_view => 'valid_term_purpose_view',
      :is_primary => false
    )
  end

  def create_taxon_concept_term_validation
    create(:inclusion_validation_rule,
      :column_names => ['taxon_concept_id', 'term_code'],
      :valid_values_view => 'valid_taxon_concept_term_view',
      :is_primary => false,
      :is_strict => true
    )
  end

  def create_taxon_concept_country_of_origin_validation
    create(:inclusion_validation_rule,
      :scope => {
        :rank => { :inclusion => [Rank::SPECIES, Rank::SUBSPECIES] },
        :source_code => { :inclusion => ['W'] },
        :country_of_origin => { :exclusion => ['XX'] }
      },
      :column_names => ['taxon_concept_id', 'country_of_origin'],
      :valid_values_view => 'valid_taxon_concept_country_of_origin_view',
      :is_primary => false,
      :is_strict => true
    )
  end

  def create_taxon_concept_exporter_validation
    create(:inclusion_validation_rule,
      :scope => {
        :rank => { :inclusion => [Rank::SPECIES, Rank::SUBSPECIES] },
        :source_code => { :inclusion => ['W'] },
        :country_of_origin => { :blank => true },
        :exporter => { :exclusion => ['XX'] }
      },
      :column_names => ['taxon_concept_id', 'exporter'],
      :valid_values_view => 'valid_taxon_concept_exporter_view',
      :is_primary => false,
      :is_strict => true
    )
  end

  def create_exporter_country_of_origin_validation
    create(:distinct_values_validation_rule,
      :column_names => ['exporter', 'country_of_origin'],
      :is_primary => false,
      :is_strict => true
    )
  end

  def create_exporter_importer_validation
    create(:distinct_values_validation_rule,
      :column_names => ['exporter', 'importer'],
      :is_primary => false,
      :is_strict => true
    )
  end

  def create_taxon_concept_source_validation
    create(:taxon_concept_source_validation_rule,
      :column_names => ['taxon_concept_id', 'source_code'],
      :is_primary => false,
      :is_strict => true
    )
  end

  def reg1997
    @_reg1997 ||=
      create(:eu_regulation, :name => 'No 938/97', :designation => eu,
        :effective_at => '1997-06-01', :end_date => '2000-12-18')
  end
  def reg2005
    @_reg2005 ||=
      create(:eu_regulation, :name => 'No 1332/2005', :designation => eu,
        :effective_at => '2005-08-22', :end_date => '2008-04-11')
  end
  def reg2008
    @_reg2008 ||=
      create(:eu_regulation, :name => 'No 318/2008', :designation => eu,
        :effective_at => '2008-04-11', :end_date => '2009-05-22')
  end
  def reg2012
    @_reg2012 ||=
      create(:eu_regulation, :name => 'No 1158/2012', :designation => eu,
        :effective_at => '2012-12-15', :end_date => '2013-08-10')
  end
  def reg2013
    @_reg2013 ||=
      create(:eu_regulation, :name => 'No 750/2013', :designation => eu,
      :effective_at => '2013-08-10', :end_date => nil, :is_current => true)
  end

  {
    territory: GeoEntityType::TERRITORY,
    country: GeoEntityType::COUNTRY,
    cites_region: GeoEntityType::CITES_REGION,
    trade: GeoEntityType::TRADE_ENTITY
  }.each do |name, geo_type|
    met_name = "#{name}_geo_entity_type"
    define_method(met_name) do
      met_name = met_name.to_s
      var = instance_variable_get("@_#{met_name}")
      return var if var
      geo_rel_type = create(:geo_entity_type, name: geo_type)
      instance_variable_set("@_#{met_name}", geo_rel_type)
    end
  end

  def contains_geo_relationship_type
    @_contains_geo_relationship_type ||=
      create(:geo_relationship_type, :name => GeoRelationshipType::CONTAINS)
  end

  {
    synonym: TaxonRelationshipType::HAS_SYNONYM,
    trade_name: TaxonRelationshipType::HAS_TRADE_NAME,
    hybrid: TaxonRelationshipType::HAS_HYBRID
  }.each do |name, rel_type|
    met_name = "#{name}_relationship_type"
    define_method(met_name) do
      met_name = met_name.to_s
      var = instance_variable_get("@_#{met_name}")
      return var if var
      relationship = create(
        :taxon_relationship_type,
        :name => rel_type,
        :is_intertaxonomic => false,
        :is_bidirectional => false
      )
      instance_variable_set("@_#{met_name}", relationship)
    end
  end
  def equal_relationship_type
    @_equal_relationship_type ||=
      create(
        :taxon_relationship_type,
        :name => TaxonRelationshipType::EQUAL_TO,
        :is_intertaxonomic => true,
        :is_bidirectional => true
      )
  end
end

module SapiSpec
  module Helpers
    def self.included(scope)
      scope.include_context :sapi
    end
  end
end
