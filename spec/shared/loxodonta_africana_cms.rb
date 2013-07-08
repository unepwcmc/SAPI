shared_context "Loxodonta africana CMS" do

  before(:all) do
    @order = create_cms_order(
      :taxon_name => create(:taxon_name, :scientific_name => 'Proboscidea'),
      :parent => cms_mammalia
    )
    @family = create_cms_family(
      :taxon_name => create(:taxon_name, :scientific_name => 'Elephantidae'),
      :parent => @order
    )
    @genus = create_cms_genus(
      :taxon_name => create(:taxon_name, :scientific_name => 'Loxodonta'),
      :parent => @family
    )
    @species = create_cms_species(
      :taxon_name => create(:taxon_name, :scientific_name => 'africana'),
      :parent => @genus
    )

    create_cms_II_addition(
     :taxon_concept => @species,
     :effective_at => '1979-01-01',
     :is_current => true
    )

    Sapi::rebuild(:except => [:taxonomy])
    self.instance_variables.each do |t|
      var = self.instance_variable_get(t)
      if var.kind_of? TaxonConcept
        self.instance_variable_set(t,MTaxonConcept.find(var.id))
        self.instance_variable_get(t).reload
      end
    end
  end
end
