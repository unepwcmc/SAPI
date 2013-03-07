#Encoding: utf-8
shared_context 'Colophon' do
  before(:all) do
    @klass = create(
      :class,
      :taxon_name => create(:taxon_name, :scientific_name => 'Insecta')
    )
    @order = create(
      :order,
      :taxon_name => create(:taxon_name, :scientific_name => 'Coleoptera'),
      :parent => @klass
    )
    @family = create(
      :family,
      :taxon_name => create(:taxon_name, :scientific_name => 'Lucanidae'),
      :parent => @order
    )
    @genus = create(
      :genus,
      :taxon_name => create(:taxon_name, :scientific_name => 'Colophon'),
      :parent => @family,
    )
    @species = create(
      :species,
      :taxon_name => create(:taxon_name, :scientific_name => 'barnardi'),
      :parent => @genus,
    )

    lc = create(
     :cites_III_addition,
     :taxon_concept => @genus,
     :effective_at => '2000-09-13',
     :is_current => true
    )

    south_africa = create(
      :country,
      :name => 'South Africa',
      :iso_code2 => 'ZA'
    )

    create(
      :listing_distribution,
      :geo_entity => south_africa,
      :listing_change => lc,
      :is_party => true
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
