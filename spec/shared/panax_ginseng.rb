shared_context "Panax ginseng" do
  before(:all) do
    @kingdom = TaxonConcept.find_by_taxon_name_id(TaxonName.find_by_scientific_name('Plantae').id)
    @order = create(
      :order,
      :taxon_name => create(:taxon_name, :scientific_name => 'Apiales'),
      :parent => @kingdom
    )
    @family = create(
      :family,
      :taxon_name => create(:taxon_name, :scientific_name => 'Araliaceae'),
      :parent => @order
    )
    @genus = create(
      :genus,
      :taxon_name => create(:taxon_name, :scientific_name => 'Panax'),
      :parent => @family
    )
    @species = create(
      :species,
      :taxon_name => create(:taxon_name, :scientific_name => 'Ginseng'),
      :parent => @genus,
      :fully_covered => false
    )

   english = create(
     :language,
     :name => 'English'
   )

    a1 = create(
      :annotation,
      :symbol => '#3',
      :parent_symbol => 'CoP11',
      :listing_change => nil
    )

    at1 = create(
      :annotation_translation,
      :language => english,
      :annotation => a1,
      :full_note => 'generic'
    )

    russia = create(
      :country,
      :name => 'Russia',
      :iso_code2 => 'RU'
    )

    l1 = create(
      :cites_II_addition,
      :taxon_concept => @species,
      :effective_at => '2000-07-19',
      :annotation_id => a1.id
    )

    create(
      :listing_distribution,
      :geo_entity => russia,
      :listing_change => l1,
      :is_party => false
    )

    a2 = create(
      :annotation,
      :listing_change => l1
    )

    at2 = create(
      :annotation_translation,
      :language => english,
      :annotation => a2,
      :full_note => 'specific'
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
