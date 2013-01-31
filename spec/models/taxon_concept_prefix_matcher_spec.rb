require 'spec_helper'

describe TaxonConceptPrefixMatcher do
  let(:taxonomy){ create(:taxonomy) }
  let!(:rank1){ create(:rank, :taxonomic_position => 1) }
  let!(:rank2){ create(:rank, :taxonomic_position => 2) }
  let!(:rank3){ create(:rank, :taxonomic_position => 2.1) }
  let!(:rank4){ create(:rank, :taxonomic_position => 3) }

  let(:taxon_concept1){
    create(:taxon_concept, :rank => rank1, :taxonomy => taxonomy,
      :taxon_name => create(:taxon_name, :scientific_name => 'AAA')
    )
  }
  let(:taxon_concept2){
    create(:taxon_concept, :rank => rank2, :taxonomy => taxonomy,
      :taxon_name => create(:taxon_name, :scientific_name => 'AAA')
    )
  }
  let(:taxon_concept3){
    create(:taxon_concept, :rank => rank3, :taxonomy => taxonomy,
      :taxon_name => create(:taxon_name, :scientific_name => 'AAB')
    )
  }

  let(:taxon_concept4){
    create(:taxon_concept, :rank => rank4, :taxonomy => taxonomy,
      :taxon_name => create(:taxon_name, :scientific_name => 'ABB')
    )
  }

  let(:parent_matcher){
    TaxonConceptPrefixMatcher.new(
      :taxonomy => {:id => taxonomy.id},
      :rank => {:id => taxon_concept4.rank_id, :scope => :parent},
      :scientific_name => 'A'
    )
  }

  specify{ parent_matcher.taxon_concepts.should == [taxon_concept2, taxon_concept3] }

  let(:ancestor_matcher){
    TaxonConceptPrefixMatcher.new(
      :taxonomy => {:id => taxonomy.id},
      :rank => {:id => taxon_concept4.rank_id, :scope => :ancestors},
      :scientific_name => 'A'
    )
  }

  specify{ ancestor_matcher.taxon_concepts.should == [taxon_concept1, taxon_concept2, taxon_concept3] }

  let(:ancestor_aa_matcher){
    TaxonConceptPrefixMatcher.new(
      :taxonomy => {:id => taxonomy.id},
      :rank => {:id => taxon_concept4.rank_id, :scope => :ancestors},
      :scientific_name => 'AAA'
    )
  }

  specify{ ancestor_matcher.taxon_concepts.should == [taxon_concept1, taxon_concept2] }

end
