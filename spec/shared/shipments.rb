#Encoding: utf-8
shared_context 'Shipments' do
  before(:each) do
    @family = create_cites_eu_family
    @genus1 = create_cites_eu_genus(
      :taxon_name => create(:taxon_name, :scientific_name => 'Foobarus'),
      :parent => @family
    )
    @taxon_concept1 = create_cites_eu_species(
      :taxon_name => create(:taxon_name, :scientific_name => 'abstractus'),
      :parent => @genus1
    )
    @genus2 = create_cites_eu_genus(
      :taxon_name => create(:taxon_name, :scientific_name => 'Nullificus'),
      :parent => @family
    )
    @taxon_concept2 = create_cites_eu_species(
      :taxon_name => create(:taxon_name, :scientific_name => 'totalus'),
      :parent => @genus2
    )
    @subspecies = create_cites_eu_subspecies(
      :parent => @taxon_concept1
    )
    @synonym_subspecies = create_cites_eu_subspecies(
      :parent => @taxon_concept1,
      :name_status => 'S'
    )
    create(
      :taxon_relationship,
      :taxon_concept => @taxon_concept2,
      :other_taxon_concept => @synonym_subspecies,
      :taxon_relationship_type => create(
        :taxon_relationship_type,
        :name => TaxonRelationshipType::HAS_SYNONYM
      )
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

    @term = create(:term, :code => 'CAV')
    @term2 = create(:term, :code => 'LIV')
    @unit = create(:unit, :code => 'KIL')
    @purpose = create(:purpose, :code => 'T')
    @source = create(:source, :code => 'W')
    @import_permit = create(:permit, :number => 'AAA')
    @export_permit1 = create(:permit, :number => 'BBB')
    @export_permit2 = create(:permit, :number => 'CCC')
    @shipment1 = create(
      :shipment,
      :taxon_concept => @taxon_concept1,
      :appendix => 'I',
      :purpose => @purpose,
      :source => @source,
      :term => @term,
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
      :taxon_concept => @taxon_concept2,
      :appendix => 'II',
      :purpose => @purpose,
      :source => @source,
      :term => @term,
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
      :taxon_concept => @taxon_concept2,
      :appendix => 'II',
      :purpose => @purpose,
      :source => @source,
      :term => @term2,
      :unit => nil,
      :importer => @portugal,
      :exporter => @argentina,
      :country_of_origin => nil,
      :year => 2013,
      :reported_by_exporter => false,
      :quantity => 10
    )
    @shipment4 = create(
      :shipment,
      :taxon_concept => @taxon_concept2,
      :appendix => 'II',
      :purpose => @purpose,
      :source => @source,
      :term => @term2,
      :unit => nil,
      :importer => @portugal,
      :exporter => @argentina,
      :country_of_origin => nil,
      :year => 2013,
      :reported_by_exporter => false,
      :quantity => 50
    )
  end
end
