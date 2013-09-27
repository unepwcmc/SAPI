shared_context "Natator depressus" do
  before(:all) do
    @order = create_cites_eu_order(
      :taxon_name => create(:taxon_name, :scientific_name => 'Testudines'),
      :parent => cites_eu_reptilia
    )
    @family = create_cites_eu_family(
      :taxon_name => create(:taxon_name, :scientific_name => 'Cheloniidae'),
      :parent => @order
    )
    @genus = create_cites_eu_genus(
      :taxon_name => create(:taxon_name, :scientific_name => 'Natator'),
      :parent => @family
    )
    @species = create_cites_eu_species(
      :taxon_name => create(:taxon_name, :scientific_name => 'depressus'),
      :parent => @genus
    )

    create_cites_II_addition(
      :taxon_concept => @species,
      :effective_at => '1975-07-01',
      :is_current => false
    )

    create_cites_II_addition(
      :taxon_concept => @species,
      :effective_at => '1977-02-04',
      :is_current => true,
      :inclusion_taxon_concept_id => @family.id
    )

    create_cites_II_addition(
      :taxon_concept => @family,
      :effective_at => '1977-02-04',
      :is_current => false
    )

    create_cites_II_deletion(
      :taxon_concept => @family,
      :effective_at => '1981-06-06',
      :is_current => false,
      :explicit_change => false
    )

    create_cites_I_addition(
      :taxon_concept => @family,
      :effective_at => '1981-06-06',
      :is_current => true
    )

    eu
    cms_designation
    Sapi.rebuild(:except => [:taxonomy])
    self.instance_variables.each do |t|
      var = self.instance_variable_get(t)
      if var.kind_of? TaxonConcept
        self.instance_variable_set(t,MTaxonConcept.find(var.id))
        self.instance_variable_get(t).reload
      end
    end
  end
end
