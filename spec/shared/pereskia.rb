shared_context "Pereskia" do
  before(:all) do
    @kingdom = TaxonConcept.find_by_taxon_name_id(TaxonName.find_by_scientific_name('Plantae').id)
    @phylum = create(
      :phylum,
      :taxon_name => create(:taxon_name, :scientific_name => 'not really sure'),
      :parent => @kingdom
    )
    @klass = create(
      :class,
      :taxon_name => create(:taxon_name, :scientific_name => 'not really sure'),
      :parent => @phylum
    )
    @order = create(
      :order,
      :taxon_name => create(:taxon_name, :scientific_name => 'Caryophyllales'),
      :parent => @klass
    )
    @family = create(
      :family,
      :taxon_name => create(:taxon_name, :scientific_name => 'Cactacea'),
      :parent => @order
    )
    @genus1 = create(
      :genus,
      :taxon_name => create(:taxon_name, :scientific_name => 'Pereskia'),
      :parent => @family,
      :listing => {:usr_cites_excluded => 't'}
    )
    @genus2 = create(
      :genus,
      :taxon_name => create(:taxon_name, :scientific_name => 'Ariocarpus'),
      :parent => @family
    )

    l1 = create(
     :cites_II_addition,
     :taxon_concept => @family,
     :effective_at => '2010-06-23',
     :is_current => true
    )
    create(
     :cites_II_addition_exception,
     :taxon_concept => @genus1,
     :effective_at => '2010-06-23',
     :parent_id => l1.id
    )
    create(
     :cites_II_addition,
     :taxon_concept => @genus2,
     :effective_at => '1975-07-01'
    )
    create(
     :cites_I_addition,
     :taxon_concept => @genus2,
     :effective_at => '1992-06-11',
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
