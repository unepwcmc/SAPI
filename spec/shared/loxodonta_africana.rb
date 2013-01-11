shared_context "Loxodonta africana" do
  before(:all) do
    @klass = TaxonConcept.find_by_taxon_name_id(TaxonName.find_by_scientific_name('Mammalia').id)
    @order = create(
      :order,
      :taxon_name => create(:taxon_name, :scientific_name => 'Proboscidea'),
      :parent => @klass
    )
    @family = create(
      :family,
      :taxon_name => create(:taxon_name, :scientific_name => 'Elephantidae'),
      :parent => @order
    )
    @genus = create(
      :genus,
      :taxon_name => create(:taxon_name, :scientific_name => 'Loxodonta'),
      :parent => @family
    )
    @species = create(
      :species,
      :taxon_name => create(:taxon_name, :scientific_name => 'Africana'),
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
    namibia = create(
      :country,
      :name => 'Namibia',
      :iso_code2 => 'NA'
    )
    zambia = create(
      :country,
      :name => 'Zambia',
      :iso_code2 => 'ZA'
    )
    zimbabwe = create(
      :country,
      :name => 'Zimbabwe',
      :iso_code2 => 'ZW'
    )
    l1 = create(
     :cites_III_addition,
     :taxon_concept => @species,
     :effective_at => '1976-02-26'
    )
    create(
      :listing_distribution,
      :geo_entity => ghana,
      :listing_change => l1
    )
    create(
     :cites_II_addition,
     :taxon_concept => @species,
     :effective_at => '1977-02-04'
    )
    create(
     :cites_I_addition,
     :taxon_concept => @species,
     :effective_at => '1990-01-18',
     :is_current => true
    )
    l2 = create(
     :cites_II_addition,
     :taxon_concept => @species,
     :effective_at => '1997-09-18'
    )
    [botswana, namibia, zimbabwe].each do |country|
      create(
        :listing_distribution,
        :geo_entity => country,
        :listing_change => l2,
        :is_party => false
      )
    end
    l3 = create(
     :cites_II_addition,
     :taxon_concept => @species,
     :effective_at => '2000-07-19',
     :is_current => true
    )
    [botswana, namibia, zambia, zimbabwe].each do |country|
      create(
        :listing_distribution,
        :geo_entity => country,
        :listing_change => l3,
        :is_party => false
      )
    end

    Sapi::rebuild(:except => [:names_and_ranks, :taxonomic_positions])
    self.instance_variables.each do |t|
      var = self.instance_variable_get(t)
      if var.kind_of? TaxonConcept
        puts var.reload.inspect
        self.instance_variable_set(t,MTaxonConcept.find(var.id))
        self.instance_variable_get(t).reload
      end
    end
  end
end