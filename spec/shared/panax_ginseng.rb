shared_context "Panax ginseng" do
  let(:russia){
    create(
      :country,
      :name => 'Russia',
      :iso_code2 => 'RU'
    )
  }
  let(:china){
    create(
      :country,
      :name => 'China',
      :iso_code2 => 'CN'
    )
  }
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
      :parent => @family,
      :data => {:cites_name_status => 'A'}
    )
    @species = create(
      :species,
      :taxon_name => create(:taxon_name, :scientific_name => 'Ginseng'),
      :parent => @genus,
      :data => {:cites_name_status => 'A'}
    )

    a1 = create(
      :annotation,
      :symbol => '#3',
      :parent_symbol => 'CoP11',
      :listing_change => nil
    )

    at1 = create(
      :annotation_translation,
      :language => Language.find_by_iso_code1('en'),
      :annotation => a1,
      :full_note => 'generic'
    )

    l1 = create(
      :cites_II_addition,
      :taxon_concept => @species,
      :effective_at => '2000-07-19',
      :annotation_id => a1.id,
      :is_current => true
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
      :language => Language.find_by_iso_code1('en'),
      :annotation => a2,
      :full_note => 'specific'
    )

    [china, russia].each do |country|
      create(
        :taxon_concept_geo_entity,
        :taxon_concept => @species,
        :geo_entity => country
      )
    end

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
