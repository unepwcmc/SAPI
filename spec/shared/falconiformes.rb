shared_context "Falconiformes" do
  before(:all) do
    @order = create_cites_eu_order(
      :taxon_name => create(:taxon_name, :scientific_name => 'Falconiformes'),
      :parent => cites_eu_aves
    )
    @family1 = create_cites_eu_family(
      :taxon_name => create(:taxon_name, :scientific_name => 'Cathartidae'),
      :parent => @order
    )
    @genus1_1 = create_cites_eu_genus(
      :taxon_name => create(:taxon_name, :scientific_name => 'Gymnogyps'),
      :parent => @family1
    )
    @species1_1 = create_cites_eu_species(
      :taxon_name => create(:taxon_name, :scientific_name => 'Californianus'),
      :parent => @genus1_1,
      :name_status => 'A'
    )
    @genus1_2 = create_cites_eu_genus(
      :taxon_name => create(:taxon_name, :scientific_name => 'Sarcoramphus'),
      :parent => @family1
    )
    @species1_2 = create_cites_eu_species(
      :taxon_name => create(:taxon_name, :scientific_name => 'Papa'),
      :parent => @genus1_2,
      :name_status => 'A'
    )
    @genus1_3 = create_cites_eu_genus(
      :taxon_name => create(:taxon_name, :scientific_name => 'Vultur'),
      :parent => @family1
    )
    #this one is not listed
    @species1_3 = create_cites_eu_species(
      :taxon_name => create(:taxon_name, :scientific_name => 'Atratus'),
      :parent => @genus1_3,
      :name_status => 'A'
    )
    @family2 = create_cites_eu_family(
      :taxon_name => create(:taxon_name, :scientific_name => 'Falconidae'),
      :parent => @order
    )
    @genus2_1 = create_cites_eu_genus(
      :taxon_name => create(:taxon_name, :scientific_name => 'Falco'),
      :parent => @family2
    )
    @species2_1 = create_cites_eu_species(
      :taxon_name => create(:taxon_name, :scientific_name => 'Araeus'),
      :parent => @genus2_1,
      :name_status => 'A'
    )
    @species2_2 = create_cites_eu_species(
      :taxon_name => create(:taxon_name, :scientific_name => 'Alopex'),
      :parent => @genus2_1,
      :name_status => 'A'
    )

    cites_lc1 = create_cites_II_addition(
     :taxon_concept => @order,
     :effective_at => '1979-06-28',
     :is_current => true
    )
    create_cites_II_exception(
     :taxon_concept => @family1,
     :effective_at => '1979-06-28',
     :parent_id => cites_lc1.id
    )
    eu_lc1 = create_eu_B_addition(
     :taxon_concept => @order,
     :effective_at => '1979-06-28',
     :is_current => true
    )
    create_eu_B_exception(
     :taxon_concept => @family1,
     :effective_at => '1979-06-28',
     :parent_id => eu_lc1.id
    )

    create_cites_I_addition(
     :taxon_concept => @species1_1,
     :effective_at => '1975-07-01',
     :is_current => true
    )
    create_eu_A_addition(
     :taxon_concept => @species1_1,
     :effective_at => '1975-07-01',
     :is_current => true
    )

    create_cites_III_addition(
     :taxon_concept => @species1_2,
     :effective_at => '1987-04-13',
     :is_current => true
    )
    create_eu_C_addition(
     :taxon_concept => @species1_2,
     :effective_at => '1987-04-13',
     :is_current => true
    )

    create_cites_II_addition(
     :taxon_concept => @family2,
     :effective_at => '1975-07-01'
    )
    create_cites_II_addition(
     :taxon_concept => @family2,
     :effective_at => '1979-06-28',
     :inclusion_taxon_concept_id => @order.id,
     :is_current => true
    )
    create_eu_B_addition(
     :taxon_concept => @family2,
     :effective_at => '1979-06-28',
     :inclusion_taxon_concept_id => @order.id,
     :is_current => true
    )

    create_cites_II_addition(
     :taxon_concept => @species2_1,
     :effective_at => '1975-07-01'
    )
    create_cites_I_addition(
     :taxon_concept => @species2_1,
     :effective_at => '1977-02-04',
     :is_current => true
    )
    create_eu_A_addition(
     :taxon_concept => @species2_1,
     :effective_at => '1977-02-04',
     :is_current => true
    )

    cms_designation
    Sapi.rebuild
    self.instance_variables.each do |t|
      var = self.instance_variable_get(t)
      if var.kind_of? TaxonConcept
        self.instance_variable_set(t,MTaxonConcept.find(var.id))
        self.instance_variable_get(t).reload
      end
    end
  end
end
