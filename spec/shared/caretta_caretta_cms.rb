shared_context "Caretta caretta CMS" do

  before(:all) do
    @order = create_cms_order(
      :taxon_name => create(:taxon_name, :scientific_name => 'Testudinata'),
      :parent => cms_reptilia
    )
    @family = create_cms_family(
      :taxon_name => create(:taxon_name, :scientific_name => 'Cheloniidae'),
      :parent => @order
    )
    @genus = create_cms_genus(
      :taxon_name => create(:taxon_name, :scientific_name => 'Caretta'),
      :parent => @family
    )
    @species = create_cms_species(
      :taxon_name => create(:taxon_name, :scientific_name => 'caretta'),
      :parent => @genus
    )

    create_cms_II_addition(
      :taxon_concept => @family,
      :effective_at => '1983-11-01',
      :is_current => true
    )

    create_cms_I_addition(
      :taxon_concept => @species,
      :effective_at => '1986-01-24',
      :is_current => true
    )

    Sapi::StoredProcedures.rebuild_cms_taxonomy_and_listings
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
