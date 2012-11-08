shared_context "Psittaciformes" do
  before(:all) do
    @klass = TaxonConcept.find_by_taxon_name_id(TaxonName.find_by_scientific_name('Aves').id)
    @order = create(
      :order,
      :taxon_name => create(:taxon_name, :scientific_name => 'Psittaciformes'),
      :parent => @klass
    )
    @family1 = create(
      :family,
      :taxon_name => create(:taxon_name, :scientific_name => 'Cacatuidae'),
      :parent => @order
    )
    @genus1_1 = create(
      :genus,
      :taxon_name => create(:taxon_name, :scientific_name => 'Probosciger'),
      :parent => @family1
    )
    @species1_1 = create(
      :species,
      :taxon_name => create(:taxon_name, :scientific_name => 'Aterrimus'),
      :parent => @genus1_1
    )
    @genus1_2 = create(
      :genus,
      :taxon_name => create(:taxon_name, :scientific_name => 'Cacatua'),
      :parent => @family1
    )
    @species1_2_1 = create(
      :species,
      :taxon_name => create(:taxon_name, :scientific_name => 'Goffiniana'),
      :parent => @genus1_2
    )
    @species1_2_2 = create(
      :species,
      :taxon_name => create(:taxon_name, :scientific_name => 'Ducorpsi'),
      :parent => @genus1_2
    )
    @family2 = create(
      :family,
      :taxon_name => create(:taxon_name, :scientific_name => 'Psittacidae'),
      :parent => @order
    )
    @genus2_1 = create(
      :genus,
      :taxon_name => create(:taxon_name, :scientific_name => 'Agapornis'),
      :parent => @family2
    )
    @species2_1 = create(
      :species,
      :taxon_name => create(:taxon_name, :scientific_name => 'Roseicollis'),
      :parent => @genus2_1
    )
    @species2_1_2 = create(
      :species,
      :taxon_name => create(:taxon_name, :scientific_name => 'Canus'),
      :parent => @genus2_1
    )
    @genus2_2 = create(
      :genus,
      :taxon_name => create(:taxon_name, :scientific_name => 'Amazona'),
      :parent => @family2
    )
    @species2_2 = create(
      :species,
      :taxon_name => create(:taxon_name, :scientific_name => 'Aestiva'),
      :parent => @genus2_2
    )
    @genus2_3 = create(
      :genus,
      :taxon_name => create(:taxon_name, :scientific_name => 'Psittacula'),
      :parent => @family2
    )
    @species2_3 = create(
      :species,
      :taxon_name => create(:taxon_name, :scientific_name => 'Krameri'),
      :parent => @genus2_3
    )

    ghana = create(
      :country,
      :name => 'Ghana',
      :iso_code2 => 'GH'
    )

    create(
     :cites_II_addition,
     :taxon_concept => @order,
     :effective_at => '1981-06-06'
    )
    create(
     :cites_II_addition,
     :taxon_concept => @order,
     :effective_at => '2005-01-12'
    )
    create(
     :cites_II_addition,
     :taxon_concept => @species1_1,
     :effective_at => '1975-07-01'
    )
    create(
     :cites_I_addition,
     :taxon_concept => @species1_1,
     :effective_at => '1987-10-22'
    )
    create(
     :cites_II_addition,
     :taxon_concept => @species1_2_1,
     :effective_at => '1981-06-06'
    )
    create(
     :cites_I_addition,
     :taxon_concept => @species1_2_1,
     :effective_at => '1992-06-11'
    )
    create(
     :cites_III_addition,
     :taxon_concept => @family2,
     :effective_at => '1976-02-26'
    )
    create(
     :cites_II_addition,
     :taxon_concept => @family2,
     :effective_at => '1981-06-06'
    )
    create(
     :cites_II_addition,
     :taxon_concept => @genus2_1,
     :effective_at => '1981-06-06'
    )
    create(
     :cites_II_addition,
     :taxon_concept => @species2_1,
     :effective_at => '1981-06-06'
    )
    create(
     :cites_deletion,
     :taxon_concept => @species2_1,
     :effective_at => '2005-01-12'
    )
    create(
     :cites_II_addition,
     :taxon_concept => @species2_2,
     :effective_at => '1981-06-06'
    )
    l1 = create(
     :cites_III_addition,
     :taxon_concept => @species2_3,
     :effective_at => '1976-02-26'
    )
    create(
      :listing_distribution,
      :geo_entity => ghana,
      :listing_change => l1
    )
    l2 = create(
     :cites_deletion,
     :taxon_concept => @species2_3,
     :effective_at => '2007-03-04',
     :is_current => true
    )
    create(
      :listing_distribution,
      :geo_entity => ghana,
      :listing_change => l2
    )

    Sapi::rebuild
    self.instance_variables.each do |t|
      var = self.instance_variable_get(t)
      if var.kind_of? TaxonConcept
        self.instance_variable_set(t,MTaxonConcept.find(var.id))
        self.instance_variable_get(t).reload
      end
    end
  end
end