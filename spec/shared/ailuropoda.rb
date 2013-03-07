#Encoding: UTF-8
shared_context "Ailuropoda" do
  before(:all) do
    @klass = create(
      :class,
      :taxon_name => create(:taxon_name, :scientific_name => 'Mammalia')
    )
    @order = create(
      :order,
      :taxon_name => create(:taxon_name, :scientific_name => 'Carnivora'),
      :parent => @klass
    )
    @family = create(
      :family,
      :taxon_name => create(:taxon_name, :scientific_name => 'Ursidae'),
      :parent => @order
    )
    @genus = create(
      :genus,
      :taxon_name => create(:taxon_name, :scientific_name => 'Ailuropoda'),
      :parent => @family
    )
    @species = create(
      :species,
      :taxon_name => create(:taxon_name, :scientific_name => 'Melanoleuca'),
      :parent => @genus
    )

    create(
     :cites_II_addition,
     :taxon_concept => @family,
     :effective_at => '1992-06-11',
     :is_current => true
    )
    create(
     :cites_I_addition,
     :taxon_concept => @species,
     :effective_at => '1984-03-14',
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