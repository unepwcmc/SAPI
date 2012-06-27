# == Schema Information
#
# Table name: taxon_concepts
#
#  id                   :integer         not null, primary key
#  parent_id            :integer
#  lft                  :integer
#  rgt                  :integer
#  rank_id              :integer         not null
#  created_at           :datetime        not null
#  updated_at           :datetime        not null
#  spcrecid             :integer
#  depth                :integer
#  designation_id       :integer         not null
#  taxon_name_id        :integer         not null
#  legacy_id            :integer
#  inherit_distribution :boolean         default(TRUE), not null
#  inherit_legislation  :boolean         default(TRUE), not null
#  inherit_references   :boolean         default(TRUE), not null
#  data                 :hstore
#  not_in_cites         :boolean         default(FALSE), not null
#  fully_covered        :boolean         default(TRUE), not null
#  listing              :hstore
#

require 'spec_helper'

describe TaxonConcept do
  context "Boa constrictor" do
    include_context "Boa constrictor"
    context "TAXONOMY" do
      describe :full_name do
        it "should be trinomen for subspecies: Boa constrictor occidentalis" do
          @subspecies.full_name.should == 'Boa constrictor occidentalis'
        end
        it "should be binomen for species: Boa constrictor" do
          @species.full_name.should == 'Boa constrictor'
        end
        it "should be single name for genus: Boa" do
          @genus.full_name.should == 'Boa'
        end
      end
      describe :rank do
        it "should be SPECIES" do
          @species.rank_name.should == 'SPECIES'
        end
      end
      describe :parents do
        it "should have Boidae as family" do
          @species.family_name == 'Boidae'
        end
        it "should have Serpentes as order" do
          @species.order_name == 'Serpentes'
        end
        it "should have Reptilia as class" do
          @species.class_name == 'Reptilia'
        end
      end
    end

    context "LISTING" do
      describe :current_listing do
        it "should be I at subspecies level Boa constrictor occidentalis" do
          @species.current_listing.should == 'I/II'
        end
        it "should be I/II at species level Boa constrictor" do
          @species.current_listing.should == 'I/II'
        end
      end
    end

  end
end
