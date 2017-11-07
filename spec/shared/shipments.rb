shared_context 'Shipments' do
  before(:each) do
    @animal_family = create_cites_eu_family(
      :parent => create_cites_eu_order(
        :parent => cites_eu_mammalia
      )
    )
    @plant_family = create_cites_eu_family(
      :parent => create_cites_eu_order(
        :parent => cites_eu_plantae
      )
    )
    @animal_genus = create_cites_eu_genus(
      :taxon_name => create(:taxon_name, :scientific_name => 'Foobarus'),
      :parent => @animal_family
    )
    @animal_genus2 = create_cites_eu_genus(
      :taxon_name => create(:taxon_name, :scientific_name => 'Barfoos'),
      :parent => @animal_family
    )
    @animal_species = create_cites_eu_species(
      :taxon_name => create(:taxon_name, :scientific_name => 'abstractus'),
      :parent => @animal_genus
    )
    @animal_species2 = create_cites_eu_species(
      :taxon_name => create(:taxon_name, :scientific_name => 'abstractus'),
      :parent => @animal_genus2
    )
    create_cites_I_addition(
      :taxon_concept => @animal_species,
      :effective_at => 1.day.ago,
      :is_current => true
    )
    create_cites_I_addition(
      :taxon_concept => @animal_species2,
      :effective_at => 1.day.ago,
      :is_current => true
    )
    @plant_genus = create_cites_eu_genus(
      :taxon_name => create(:taxon_name, :scientific_name => 'Nullificus'),
      :parent => @plant_family
    )
    @plant_species = create_cites_eu_species(
      :taxon_name => create(:taxon_name, :scientific_name => 'totalus'),
      :parent => @plant_genus
    )
    create_cites_II_addition(
      :taxon_concept => @plant_species,
      :effective_at => 1.day.ago,
      :is_current => true
    )

    @subspecies = create_cites_eu_subspecies(
      :parent => @animal_species
    )
    @synonym_subspecies = create_cites_eu_subspecies(
      :parent => @animal_species,
      :name_status => 'S'
    )
    @subspecies2 = create_cites_eu_subspecies(
      :parent => @animal_species2
    )
    @synonym_subspecies2 = create_cites_eu_subspecies(
      :parent => @animal_species2,
      :name_status => 'S'
    )
    create(
      :taxon_relationship,
      :taxon_concept => @plant_species,
      :other_taxon_concept => @synonym_subspecies,
      :taxon_relationship_type => synonym_relationship_type
    )

    @trade_name = create_cites_eu_species(
      :name_status => 'T'
    )
    @status_N_species = create_cites_eu_species(
      :name_status => 'N'
    )
    create(
      :taxon_relationship,
      :taxon_concept => @plant_species,
      :other_taxon_concept => @trade_name,
      :taxon_relationship_type => trade_name_relationship_type
    )

    country = create(:geo_entity_type, :name => 'COUNTRY')
    @argentina = create(:geo_entity,
                        :geo_entity_type => country,
                        :name => 'Argentina',
                        :iso_code2 => 'AR'
                       )

    @portugal = create(:geo_entity,
                       :geo_entity_type => country,
                       :name => 'Portugal',
                       :iso_code2 => 'PT'
                      )

    @term_cav = create(:term, :code => 'CAV')
    @term_liv = create(:term, :code => 'LIV')
    @unit = create(:unit, :code => 'KIL')
    @purpose = create(:purpose, :code => 'T')
    @source = create(:source, :code => 'C')
    @source_wild = create(:source, :code => 'W')
    @source_unknown = create(:source, :code => 'U')
    @import_permit = create(:permit, :number => 'AAA')
    @export_permit1 = create(:permit, :number => 'BBB')
    @export_permit2 = create(:permit, :number => 'CCC')
    @shipment1 = create(
      :shipment,
      :taxon_concept => @animal_species,
      :appendix => 'I',
      :purpose => @purpose,
      :source => @source,
      :term => @term_cav,
      :unit => @unit,
      :importer => @argentina,
      :exporter => @portugal,
      :country_of_origin => @argentina,
      :year => 2012,
      :reported_by_exporter => true,
      :import_permit_number => 'AAA',
      :export_permit_number => 'BBB;CCC',
      :origin_permit_number => 'EEE',
      :quantity => 20
    )
    @shipment2 = create(
      :shipment,
      :taxon_concept => @plant_species,
      :appendix => 'II',
      :purpose => @purpose,
      :source => @source_wild,
      :term => @term_cav,
      :unit => @unit,
      :importer => @portugal,
      :exporter => @argentina,
      :country_of_origin => @portugal,
      :year => 2013,
      :reported_by_exporter => false,
      :quantity => 10
    )
    @shipment3 = create(
      :shipment,
      :taxon_concept => @plant_species,
      :appendix => 'II',
      :purpose => @purpose,
      :source => @source_wild,
      :term => @term_liv,
      :unit => nil,
      :importer => @portugal,
      :exporter => @argentina,
      :country_of_origin => nil,
      :year => 2013,
      :reported_by_exporter => false,
      :quantity => 25
    )
    @shipment4 = create(
      :shipment,
      :taxon_concept => @animal_species,
      :appendix => 'II',
      :purpose => @purpose,
      :source => @source_wild,
      :term => @term_liv,
      :unit => nil,
      :importer => @portugal,
      :exporter => @argentina,
      :country_of_origin => nil,
      :year => 2013,
      :reported_by_exporter => false,
      :quantity => 35
    )
    @shipment5 = create(
      :shipment,
      :taxon_concept => @plant_species,
      :appendix => 'II',
      :purpose => @purpose,
      :source => @source_unknown,
      :term => @term_liv,
      :unit => nil,
      :importer => @portugal,
      :exporter => @argentina,
      :country_of_origin => nil,
      :year => 2013,
      :reported_by_exporter => false,
      :quantity => 10
    )
    @shipment6 = create(
      :shipment,
      :taxon_concept => @plant_species,
      :appendix => 'II',
      :purpose => @purpose,
      :source => nil,
      :term => @term_liv,
      :unit => nil,
      :importer => @portugal,
      :exporter => @argentina,
      :country_of_origin => nil,
      :year => 2013,
      :reported_by_exporter => false,
      :quantity => 50
    )
    @shipment7 = create(
      :shipment,
      :taxon_concept => @animal_species2,
      :appendix => 'II',
      :purpose => @purpose,
      :source => @source,
      :term => @term_cav,
      :unit => @unit,
      :importer => @argentina,
      :exporter => @portugal,
      :country_of_origin => @argentina,
      :year => 2014,
      :reported_by_exporter => true,
      :import_permit_number => 'FFF',
      :export_permit_number => 'DDD;KKK',
      :origin_permit_number => 'EEE',
      :quantity => 30
    )
  end
end
