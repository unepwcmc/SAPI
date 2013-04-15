shared_context "Psittaciformes" do
  let(:country){
    create(:geo_entity_type, :name => GeoEntityType::COUNTRY)
  }
  let(:ghana){
    create(
      :geo_entity,
      :geo_entity_type => country,
      :name => 'Ghana',
      :iso_code2 => 'GH'
    )
  }
  before(:all) do
    @order = create_cites_eu_order(
      :taxon_name => create(:taxon_name, :scientific_name => 'Psittaciformes'),
      :parent => cites_eu_aves
    )
    @family1 = create_cites_eu_family(
      :taxon_name => create(:taxon_name, :scientific_name => 'Cacatuidae'),
      :parent => @order
    )
    @genus1_1 = create_cites_eu_genus(
      :taxon_name => create(:taxon_name, :scientific_name => 'Probosciger'),
      :parent => @family1
    )
    @species1_1 = create_cites_eu_species(
      :taxon_name => create(:taxon_name, :scientific_name => 'Aterrimus'),
      :parent => @genus1_1,
      :name_status => 'A'
    )
    @genus1_2 = create_cites_eu_genus(
      :taxon_name => create(:taxon_name, :scientific_name => 'Cacatua'),
      :parent => @family1
    )
    @species1_2_1 = create_cites_eu_species(
      :taxon_name => create(:taxon_name, :scientific_name => 'Goffiniana'),
      :parent => @genus1_2,
      :name_status => 'A'
    )
    @species1_2_2 = create_cites_eu_species(
      :taxon_name => create(:taxon_name, :scientific_name => 'Ducorpsi'),
      :parent => @genus1_2,
      :name_status => 'A'
    )
    @family2 = create_cites_eu_family(
      :taxon_name => create(:taxon_name, :scientific_name => 'Psittacidae'),
      :parent => @order
    )
    @genus2_1 = create_cites_eu_genus(
      :taxon_name => create(:taxon_name, :scientific_name => 'Agapornis'),
      :parent => @family2
    )
    @species2_1 = create_cites_eu_species(
      :taxon_name => create(:taxon_name, :scientific_name => 'Roseicollis'),
      :parent => @genus2_1,
      :name_status => 'A'
    )
    @species2_1_2 = create_cites_eu_species(
      :taxon_name => create(:taxon_name, :scientific_name => 'Canus'),
      :parent => @genus2_1,
      :name_status => 'A'
    )
    @genus2_2 = create_cites_eu_genus(
      :taxon_name => create(:taxon_name, :scientific_name => 'Amazona'),
      :parent => @family2
    )
    @species2_2 = create_cites_eu_species(
      :taxon_name => create(:taxon_name, :scientific_name => 'Aestiva'),
      :parent => @genus2_2,
      :name_status => 'A'
    )
    @genus2_3 = create_cites_eu_genus(
      :taxon_name => create(:taxon_name, :scientific_name => 'Psittacula'),
      :parent => @family2
    )
    @species2_3 = create_cites_eu_species(
      :taxon_name => create(:taxon_name, :scientific_name => 'Krameri'),
      :parent => @genus2_3,
      :name_status => 'A'
    )

    create_cites_II_addition(
     :taxon_concept => @order,
     :effective_at => '1981-06-06'
    )
    create_cites_II_addition(
     :taxon_concept => @order,
     :effective_at => '2005-01-12',
     :is_current => true
    )
    create_eu_B_addition(
     :taxon_concept => @order,
     :effective_at => '2005-01-12',
     :is_current => true
    )

    create_cites_II_addition(
     :taxon_concept => @species1_1,
     :effective_at => '1975-07-01'
    )
    create_cites_I_addition(
     :taxon_concept => @species1_1,
     :effective_at => '1987-10-22',
     :is_current => true
    )
    create_eu_A_addition(
     :taxon_concept => @species1_1,
     :effective_at => '1987-10-22',
     :is_current => true
    )

    create_cites_II_addition(
     :taxon_concept => @species1_2_1,
     :effective_at => '1981-06-06'
    )
    create_cites_I_addition(
     :taxon_concept => @species1_2_1,
     :effective_at => '1992-06-11',
     :is_current => true
    )
    create_eu_A_addition(
     :taxon_concept => @species1_2_1,
     :effective_at => '1992-06-11',
     :is_current => true
    )

    create_cites_III_addition(
     :taxon_concept => @family2,
     :effective_at => '1976-02-26'
    )
    create_cites_II_addition(
     :taxon_concept => @family2,
     :effective_at => '1981-06-06',
     :is_current => true
    )
    create_eu_B_addition(
     :taxon_concept => @family2,
     :effective_at => '1981-06-06',
     :is_current => true
    )

    create_cites_II_addition(
     :taxon_concept => @genus2_1,
     :effective_at => '1981-06-06'
    )
    create_cites_II_addition(
     :taxon_concept => @species2_1,
     :effective_at => '1981-06-06'
    )
    create_cites_II_deletion(
     :taxon_concept => @species2_1,
     :effective_at => '2005-01-12',
     :is_current => true
    )
    create_eu_B_deletion(
     :taxon_concept => @species2_1,
     :effective_at => '2005-01-12',
     :is_current => true
    )

    create_cites_II_addition(
     :taxon_concept => @species2_2,
     :effective_at => '1981-06-06',
     :is_current => true
    )
    create_eu_B_addition(
     :taxon_concept => @species2_2,
     :effective_at => '1981-06-06',
     :is_current => true
    )

    cites_lc1 = create_cites_III_addition(
     :taxon_concept => @species2_3,
     :effective_at => '1976-02-26'
    )
    create(
      :listing_distribution,
      :geo_entity => ghana,
      :listing_change => cites_lc1
    )
    cites_lc2 = create_cites_III_deletion(
     :taxon_concept => @species2_3,
     :effective_at => '2007-03-04',
     :is_current => true
    )
    create(
      :listing_distribution,
      :geo_entity => ghana,
      :listing_change => cites_lc2
    )
    eu_lc2 = create_eu_C_deletion(
     :taxon_concept => @species2_3,
     :effective_at => '2007-03-04',
     :is_current => true
    )
    create(
      :listing_distribution,
      :geo_entity => ghana,
      :listing_change => eu_lc2
    )

    Sapi::rebuild(:except => [:taxonomy])
    self.instance_variables.each do |t|
      var = self.instance_variable_get(t)
      if var.kind_of? TaxonConcept
        self.instance_variable_set(t,MTaxonConcept.find(var.id))
        self.instance_variable_get(t).reload
      end
    end
  end
end
