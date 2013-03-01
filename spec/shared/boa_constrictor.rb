shared_context "Boa constrictor" do
  before(:all) do
    @klass = TaxonConcept.find_by_taxon_name_id(TaxonName.find_by_scientific_name('Reptilia').id)
    @order = create(
      :order,
      :taxon_name => create(:taxon_name, :scientific_name => 'Serpentes'),
      :parent => @klass
    )
    @family = create(
      :family,
      :taxon_name => create(:taxon_name, :scientific_name => 'Boidae'),
      :parent => @order
    )
    @genus = create(
      :genus,
      :taxon_name => create(:taxon_name, :scientific_name => 'Boa'),
      :parent => @family
    )
    @species = create(
      :species,
      :taxon_name => create(:taxon_name, :scientific_name => 'Constrictor'),
      :parent => @genus
    )
    @subspecies1 = create(
      :subspecies,
      :taxon_name => create(:taxon_name, :scientific_name => 'Occidentalis'),
      :parent => @species
    )
    @subspecies2 = create(
      :subspecies,
      :taxon_name => create(:taxon_name, :scientific_name => 'Constrictor'),
      :parent => @species
    )

  #Boidae
    create(
      :cites_II_addition,
      :taxon_concept => @family,
      :effective_at => '1977-02-04',
      :is_current => true
    )

  #Boa constrictor
    create(
     :cites_II_addition,
     :taxon_concept => @species,
     :effective_at => '1975-07-01',
     :is_current => true
    )
    # create(
    # :cites_II_reservation,
    # :geo_entity => GB,
    # :taxon_concept => @species,
    # :effective_at => '1976-10-31'
    # )
    create(
     :cites_II_addition,
     :taxon_concept => @species,
     :effective_at => '1977-02-04',
     :inclusion_taxon_concept_id => @family.id,
     :is_current => true
    )
    # create(
    # :cites_II_withdrawal,
    # :geo_entity => GB,
    # :taxon_concept => @species,
    # :effective_at => '1978-03-07'
    # )
    #Boa constrictor occidentalis
    create(
     :cites_II_addition,
     :taxon_concept => @subspecies1,
     :effective_at => '1977-02-04',
     :inclusion_taxon_concept_id => @family.id
    )
    # create(
    # :cites_II_deletion,
    # :taxon_concept => @subspecies,
    # :effective_at => '1987-10-22'
    # )
    create(
     :cites_I_addition,
     :taxon_concept => @subspecies1,
     :effective_at => '1987-10-22',
     :is_current => true
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
