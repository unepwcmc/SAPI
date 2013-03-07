shared_context "Tapiridae" do
  before(:all) do
    @klass = create(
      :class,
      :taxon_name => create(:taxon_name, :scientific_name => 'Mammalia')
    )
    @order = create(
      :order,
      :taxon_name => create(:taxon_name, :scientific_name => 'Perissodactyla'),
      :parent => @klass
    )
    @family = create(
      :family,
      :taxon_name => create(:taxon_name, :scientific_name => 'Tapiridae'),
      :parent => @order
    )
    @genus = create(
      :genus,
      :taxon_name => create(:taxon_name, :scientific_name => 'Tapirus'),
      :parent => @family
    )
    ['Bairdii', 'Indicus', 'Pinchaque', 'Terrestris'].each do |n|
      @species = create(
        :species,
        :taxon_name => create(:taxon_name, :scientific_name => n),
        :parent => @genus,
      :name_status => 'A'
      )
    end

    create(
     :cites_I_addition,
     :taxon_concept => @family,
     :effective_at => '1975-07-01',
     :is_current => true
    )
    create(
     :cites_II_addition,
     :taxon_concept => @species,
     :effective_at => '1977-02-04',
     :is_current => true
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
