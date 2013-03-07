shared_context "Mellivora capensis" do
  before(:all) do
    @klass = create(
      :class,
      :taxon_name => create(:taxon_name, :scientific_name => 'Mammalia')
    )
    @order = create(
      :order,
      :taxon_name => create(:taxon_name, :scientific_name => 'Carnivora'),
      :parent => @klass
    )
    @family = create(
      :family,
      :taxon_name => create(:taxon_name, :scientific_name => 'Mustelinae'),
      :parent => @order
    )
    @genus = create(
      :genus,
      :taxon_name => create(:taxon_name, :scientific_name => 'Mellivora'),
      :parent => @family
    )
    @species = create(
      :species,
      :taxon_name => create(:taxon_name, :scientific_name => 'Capensis'),
      :parent => @genus
    )

    ghana = create(
      :country,
      :name => 'Ghana',
      :iso_code2 => 'GH'
    )
    botswana = create(
      :country,
      :name => 'Botswana',
      :iso_code2 => 'BW'
    )
    l1 = create(
     :cites_III_addition,
     :taxon_concept => @species,
     :effective_at => '1976-02-26',
     :is_current => false
    )
    create(
      :listing_distribution,
      :geo_entity => ghana,
      :listing_change => l1
    )
    l2 = create(
     :cites_III_addition,
     :taxon_concept => @species,
     :effective_at => '1978-04-24',
     :is_current => true
    )
    create(
      :listing_distribution,
      :geo_entity => botswana,
      :listing_change => l2
    )
    l3 = create(
     :cites_III_deletion,
     :taxon_concept => @species,
     :effective_at => '2007-03-04',
     :is_current => true
    )
    create(
      :listing_distribution,
      :geo_entity => ghana,
      :listing_change => l3
    )

    Sapi::rebuild(:except => [:names_and_ranks, :taxonomic_positions])
    self.instance_variables.each do |t|
      var = self.instance_variable_get(t)
      if var.kind_of? TaxonConcept
        self.instance_variable_set(t,MTaxonConcept.find(var.id))
        self.instance_variable_get(t).reload
      end
    end
  end
end
