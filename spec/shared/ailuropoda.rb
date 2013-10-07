#Encoding: UTF-8
shared_context "Ailuropoda" do
  before(:all) do
    @order = create_cites_eu_order(
      :taxon_name => create(:taxon_name, :scientific_name => 'Carnivora'),
      :parent => cites_eu_mammalia
    )
    @family = create_cites_eu_family(
      :taxon_name => create(:taxon_name, :scientific_name => 'Ursidae'),
      :parent => @order
    )
    @genus = create_cites_eu_genus(
      :taxon_name => create(:taxon_name, :scientific_name => 'Ailuropoda'),
      :parent => @family
    )
    @species = create_cites_eu_species(
      :taxon_name => create(:taxon_name, :scientific_name => 'Melanoleuca'),
      :parent => @genus
    )

    create_cites_II_addition(
     :taxon_concept => @family,
     :effective_at => '1992-06-11',
     :is_current => true
    )
    create_eu_B_addition(
     :taxon_concept => @family,
     :effective_at => '1992-06-11',
     :is_current => true
    )
    create_cites_I_addition(
     :taxon_concept => @species,
     :effective_at => '1984-03-14',
     :is_current => true
    )
    create_eu_A_addition(
     :taxon_concept => @species,
     :effective_at => '1984-03-14',
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
