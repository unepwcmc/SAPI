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

    create(
     :cites_II_addition,
     :taxon_concept => @species,
     :effective_at => '2000-07-19'
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
