shared_context "Boa constrictor" do
  before(:all) do
    @order = create_cites_eu_order(
      :taxon_name => create(:taxon_name, :scientific_name => 'Serpentes'),
      :parent => cites_eu_reptilia
    )
    @family = create_cites_eu_family(
      :taxon_name => create(:taxon_name, :scientific_name => 'Boidae'),
      :parent => @order
    )
    @genus = create_cites_eu_genus(
      :taxon_name => create(:taxon_name, :scientific_name => 'Boa'),
      :parent => @family
    )
    @species = create_cites_eu_species(
      :taxon_name => create(:taxon_name, :scientific_name => 'Constrictor'),
      :parent => @genus
    )
    @subspecies1 = create_cites_eu_subspecies(
      :taxon_name => create(:taxon_name, :scientific_name => 'Occidentalis'),
      :parent => @species
    )
    @subspecies2 = create_cites_eu_subspecies(
      :taxon_name => create(:taxon_name, :scientific_name => 'Constrictor'),
      :parent => @species
    )

  #Boidae
    create_cites_II_addition(
      :taxon_concept => @family,
      :effective_at => '1977-02-04',
      :is_current => true
    )
    create_eu_B_addition(
      :taxon_concept => @family,
      :effective_at => '1977-02-04',
      :is_current => true
    )

    create_cites_II_addition(
     :taxon_concept => @species,
     :effective_at => '1975-07-01',
     :is_current => true
    )
    create_eu_B_addition(
     :taxon_concept => @species,
     :effective_at => '1975-07-01',
     :is_current => true
    )

    create_cites_II_addition(
     :taxon_concept => @species,
     :effective_at => '1977-02-04',
     :inclusion_taxon_concept_id => @family.id,
     :is_current => true
    )
    create_eu_B_addition(
     :taxon_concept => @species,
     :effective_at => '1977-02-04',
     :inclusion_taxon_concept_id => @family.id,
     :is_current => true
    )

    create_cites_II_addition(
     :taxon_concept => @subspecies1,
     :effective_at => '1977-02-04',
     :inclusion_taxon_concept_id => @family.id
    )

    create_cites_I_addition(
     :taxon_concept => @subspecies1,
     :effective_at => '1987-10-22',
     :is_current => true
    )
    create_eu_A_addition(
     :taxon_concept => @subspecies1,
     :effective_at => '1987-10-22',
     :is_current => true
    )

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
