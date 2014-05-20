shared_context "Boa constrictor" do
  let(:en){
   create(:language, :name => 'Spanish', :iso_code1 => 'ES', :iso_code3 => 'SPA')
   create(:language, :name => 'French', :iso_code1 => 'FR', :iso_code3 => 'FRA')   
   create(:language, :name => 'English', :iso_code1 => 'EN', :iso_code3 => 'ENG') 
  }
  let(:has_synonym){
    create(
      :taxon_relationship_type, :name => TaxonRelationshipType::HAS_SYNONYM
    )
  }
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
      :parent => @genus,
      :common_names => [
        create(:common_name, :name => 'Red-tailed boa', :language => en)
      ]
    )
    @subspecies1 = create_cites_eu_subspecies(
      :taxon_name => create(:taxon_name, :scientific_name => 'Occidentalis'),
      :parent => @species
    )
    @subspecies2 = create_cites_eu_subspecies(
      :taxon_name => create(:taxon_name, :scientific_name => 'Constrictor'),
      :parent => @species
    )
    @synonym = create_cites_eu_species(
      :full_name => 'Constrictor constrictor',
      :name_status => 'S'
    )
    create(
      :taxon_relationship,
      :taxon_relationship_type => has_synonym,
      :taxon_concept => @species,
      :other_taxon_concept => @synonym
    )

    create_cites_II_addition(
     :taxon_concept => @species,
     :effective_at => '1975-07-01'
    )
    create_cites_II_addition(
      :taxon_concept => @family,
      :effective_at => '1977-02-04',
      :is_current => true
    )
    create_cites_II_addition(
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

    create_eu_B_addition(
      :taxon_concept => @family,
      :effective_at => '2013-08-10',
      :event => reg2013,
      :is_current => true
    )
    create_eu_A_addition(
     :taxon_concept => @subspecies1,
      :effective_at => '2013-08-10',
      :event => reg2013,
     :is_current => true
    )

    Sapi::StoredProcedures.rebuild_cites_taxonomy_and_listings
    self.instance_variables.each do |t|
      var = self.instance_variable_get(t)
      if var.kind_of? TaxonConcept
        self.instance_variable_set(t,MTaxonConcept.find(var.id))
        self.instance_variable_get(t).reload
        self.instance_variable_set(:"#{t}_ac",
          MAutoCompleteTaxonConcept.
          where(:id => var.id).first
        )
      end
    end
  end
end
