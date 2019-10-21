shared_context "Notomys aquilo" do
  before(:all) do
    @order = create_cites_eu_order(
      :taxon_name => create(:taxon_name, :scientific_name => 'Rodentia'),
      :parent => cites_eu_mammalia
    )
    @family = create_cites_eu_family(
      :taxon_name => create(:taxon_name, :scientific_name => 'Muridae'),
      :parent => @order
    )
    @genus = create_cites_eu_genus(
      :taxon_name => create(:taxon_name, :scientific_name => 'Notomys'),
      :parent => @family
    )
    @species = create_cites_eu_species(
      :taxon_name => create(:taxon_name, :scientific_name => 'aquilo'),
      :parent => @genus,
      :name_status => 'A'
    )

    create_cites_I_addition(
      :taxon_concept => @species,
      :effective_at => '1975-07-01'
    )
    create_cites_II_addition(
      :taxon_concept => @species,
      :effective_at => '1979-06-28',
      :inclusion_taxon_concept_id => @genus.id,
      :is_current => true
    )
    cites_del = create_cites_II_deletion(
      :taxon_concept => @genus,
      :effective_at => '1987-10-22',
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
