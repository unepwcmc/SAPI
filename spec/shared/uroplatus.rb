#Encoding: utf-8
shared_context 'Uroplatus' do
  before(:all) do
    @klass = TaxonConcept.find_by_taxon_name_id(TaxonName.find_by_scientific_name('Reptilia').id)
    @order = create(
      :order,
      :taxon_name => create(:taxon_name, :scientific_name => 'Sauria'),
      :parent => @klass
    )
    @family = create(
      :family,
      :taxon_name => create(:taxon_name, :scientific_name => 'Gekkonidae'),
      :parent => @order
    )
    @genus = create(
      :genus,
      :taxon_name => create(:taxon_name, :scientific_name => 'Uroplatus'),
      :parent => @family,
      :data => {:usr_no_std_ref => true}
    )
    @species1 = create(
      :species,
      :taxon_name => create(:taxon_name, :scientific_name => 'Alluaudi'),
      :parent => @genus
    )
    @species2 = create(
      :species,
      :taxon_name => create(:taxon_name, :scientific_name => 'Giganteus'),
      :parent => @genus
    )

    create(
     :cites_II_addition,
     :taxon_concept => @genus,
     :effective_at => '2005-01-12',
     :is_current => true
    )

    @ref = create(
      :reference,
      :author => 'Glaw, F., Kosuch, J., Henkel, W. F., Sound, P. and Böhme, W.',
      :title =>
        'Genetic and morphological variation of the leaf-tailed gecko Uroplatus
        fimbriatus from Madagascar, with description of a new giant species.',
      :year => 2006
    )

    create(
      :taxon_concept_reference,
      :taxon_concept => @species2,
      :reference => @ref,
      :data => {:usr_is_std_ref => 't'}
    )

    Sapi::rebuild
    self.instance_variables.each do |t|
      var = self.instance_variable_get(t)
      if var.kind_of? TaxonConcept
        self.instance_variable_set(t,MTaxonConcept.find(var.id))
        self.instance_variable_get(t).reload
      end
    end
  end
end
