shared_context "Hirudo medicinalis" do
  before(:all) do
    @klass = create_cites_eu_class(
      :taxon_name => create(:taxon_name, :scientific_name => 'Hirudinoidea')
    )
    @order = create_cites_eu_order(
      :taxon_name => create(:taxon_name, :scientific_name => 'Arhynchobdellida'),
      :parent => @klass
    )
    @family = create_cites_eu_family(
      :taxon_name => create(:taxon_name, :scientific_name => 'Hirudinidae'),
      :parent => @order
    )
    @genus = create_cites_eu_genus(
      :taxon_name => create(:taxon_name, :scientific_name => 'Hirudo'),
      :parent => @family
    )
    @species = create_cites_eu_species(
      :taxon_name => create(:taxon_name, :scientific_name => 'Medicinalis'),
      :parent => @genus,
      :name_status => 'A'
    )

    create_cites_II_addition(
     :taxon_concept => @species,
     :effective_at => '1987-10-22'
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