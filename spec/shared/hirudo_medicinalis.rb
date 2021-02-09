shared_context "Hirudo medicinalis" do
  before(:all) do
    @order = create_cites_eu_order(
      :taxon_name => create(:taxon_name, :scientific_name => 'Arhynchobdellida'),
      :parent => cites_eu_hirudinoidea
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
      :effective_at => '1987-10-22',
      :is_current => true
    )
    create_eu_B_addition(
      :taxon_concept => @species,
      :effective_at => '2013-10-08',
      :event => reg2013,
      :is_current => true
    )

    Sapi::StoredProcedures.rebuild_cites_taxonomy_and_listings
    self.instance_variables.each do |t|
      #Skip old sapi context let statements,
      #which are now instance variables starting with _
      next if t.to_s.include?('@_')
      var = self.instance_variable_get(t)
      if var.kind_of? TaxonConcept
        self.instance_variable_set(t, MTaxonConcept.find(var.id))
        self.instance_variable_get(t).reload
      end
    end

  end

end
