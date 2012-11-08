shared_context "Canis lupus" do
  before(:all) do
    @klass = TaxonConcept.find_by_taxon_name_id(TaxonName.find_by_scientific_name('Mammalia').id)
    @order = create(
      :order,
      :taxon_name => create(:taxon_name, :scientific_name => 'Carnivora'),
      :parent => @klass
    )
    @family = create(
      :family,
      :taxon_name => create(:taxon_name, :scientific_name => 'Canidae'),
      :parent => @order
    )
    @genus = create(
      :genus,
      :taxon_name => create(:taxon_name, :scientific_name => 'Canis'),
      :parent => @family
    )
    @species = create(
      :species,
      :taxon_name => create(:taxon_name, :scientific_name => 'Lupus'),
      :parent => @genus
    )

    bhutan = create(
      :country,
      :name => 'Bhutan',
      :iso_code2 => 'BT'
    )
    india = create(
      :country,
      :name => 'India',
      :iso_code2 => 'IN'
    )
    nepal = create(
      :country,
      :name => 'Nepal',
      :iso_code2 => 'NP'
    )
    pakistan = create(
      :country,
      :name => 'Pakistan',
      :iso_code2 => 'PK'
    )
    create(
     :cites_II_addition,
     :taxon_concept => @species,
     :effective_at => '1977-02-04'
    )
    l1 = create(
     :cites_I_addition,
     :taxon_concept => @species,
     :effective_at => '1979-06-28'
    )
    [bhutan, india, nepal, pakistan].each do |country|
      create(
        :listing_distribution,
        :geo_entity => country,
        :listing_change => l1,
        :is_party => false
      )
    end
    create(
     :cites_II_addition,
     :taxon_concept => @species,
     :effective_at => '1979-06-28'
    )
    l2 = create(
     :cites_I_addition,
     :taxon_concept => @species,
     :effective_at => '2010-06-23',
     :is_current => true
    )
    [bhutan, india, nepal, pakistan].each do |country|
      create(
        :listing_distribution,
        :geo_entity => country,
        :listing_change => l2,
        :is_party => false
      )
    end
    create(
     :cites_II_addition,
     :taxon_concept => @species,
     :effective_at => '2010-06-23',
     :is_current => true
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
