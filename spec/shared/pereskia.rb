shared_context "Pereskia" do
  before(:all) do
    @order = create_cites_eu_order(
      :taxon_name => create(:taxon_name, :scientific_name => 'Caryophyllales'),
      :parent => cites_eu_plantae.reload # reload is needed for full name
    )
    @family = create_cites_eu_family(
      :taxon_name => create(:taxon_name, :scientific_name => 'Cactacea'),
      :parent => @order
    )
    @genus1 = create_cites_eu_genus(
      :taxon_name => create(:taxon_name, :scientific_name => 'Pereskia'),
      :parent => @family,
      :listing => {:usr_cites_excluded => 't'}
    )
    @genus2 = create_cites_eu_genus(
      :taxon_name => create(:taxon_name, :scientific_name => 'Ariocarpus'),
      :parent => @family
    )

    cites_lc1 = create_cites_II_addition(
     :taxon_concept => @family,
     :effective_at => '2010-06-23',
     :is_current => true
    )
    create_cites_II_exception(
     :taxon_concept => @genus1,
     :effective_at => '2010-06-23',
     :parent_id => cites_lc1.id
    )
    eu_lc1 = create_eu_B_addition(
     :taxon_concept => @family,
     :effective_at => '2010-06-23',
     :is_current => true
    )
    create_eu_B_exception(
     :taxon_concept => @genus1,
     :effective_at => '2010-06-23',
     :parent_id => eu_lc1.id
    )

    create_cites_II_addition(
     :taxon_concept => @genus2,
     :effective_at => '1975-07-01'
    )
    create_cites_I_addition(
     :taxon_concept => @genus2,
     :effective_at => '1992-06-11',
     :is_current => true
    )
    create_eu_A_addition(
     :taxon_concept => @genus2,
     :effective_at => '1992-06-11',
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
