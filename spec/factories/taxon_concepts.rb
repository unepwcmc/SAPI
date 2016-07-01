FactoryGirl.define do
  factory :taxon_concept, :aliases => [:other_taxon_concept] do
    taxonomy
    rank
    taxon_name
    taxonomic_position '1'
    name_status 'A'
    data {}
    listing {}
    before(:create) { |tc|
      if tc.parent.nil? && ['A', 'N'].include?(tc.name_status) && tc.rank.try(:name) != 'KINGDOM'
        tc.parent = create(
          :taxon_concept,
          taxonomy: tc.taxonomy,
          name_status: 'A',
          rank: create(:rank, name: tc.rank.parent_rank_name) # this should not produce duplicates
        )
      end
    }
  end
end
