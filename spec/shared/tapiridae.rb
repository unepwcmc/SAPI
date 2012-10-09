shared_context "Tapiridae" do
  before(:all) do
    @klass = TaxonConcept.find_by_taxon_name_id(TaxonName.find_by_scientific_name('Mammalia').id)
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
        :parent => @genus
      )
    end

    create(
     :cites_I_addition,
     :taxon_concept => @family,
     :effective_at => '1975-07-01'
    )
    create(
     :cites_II_addition,
     :taxon_concept => @species,
     :effective_at => '1977-02-04'
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
