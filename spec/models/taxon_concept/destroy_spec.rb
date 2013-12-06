#Encoding: utf-8
require 'spec_helper'

describe TaxonConcept do
  describe :destroy do
    context "general" do
      before(:each){ @taxon_concept = create_cms_species }
      context "when no dependent objects attached" do
        specify { @taxon_concept.destroy.should be_true }
      end
      context "when distributions" do
        before(:each){ create(:distribution, :taxon_concept => @taxon_concept)}
        specify { @taxon_concept.destroy.should be_true}
      end
      context "when common names" do
        before(:each){ create(:taxon_common, :taxon_concept => @taxon_concept)}
        specify { @taxon_concept.destroy.should be_true }
      end
      context "when references" do
        before(:each){ create(:taxon_concept_reference, :taxon_concept => @taxon_concept)}
        specify { @taxon_concept.destroy.should be_true }
      end
    end
    context "CMS" do
      before(:each){ @taxon_concept = create_cms_species }
      context "when taxon instruments" do
        before(:each){ create(:taxon_instrument, :taxon_concept => @taxon_concept)}
        specify { @taxon_concept.destroy.should be_false }
      end
    end
    context "CITES / EU" do
      before(:each){ @taxon_concept = create_cites_eu_species }
      context "when listing changes" do
        before(:each){ create_cites_I_addition(:taxon_concept => @taxon_concept)}
        specify { @taxon_concept.destroy.should be_false }
      end
      context "when CITES quotas" do
        before(:each){ create(:quota, :taxon_concept => @taxon_concept, :geo_entity => create(:geo_entity))}
        specify { @taxon_concept.destroy.should be_false }
      end
      context "when CITES suspensions" do
        before(:each){ create(:cites_suspension, :taxon_concept => @taxon_concept, :start_notification => create(:cites_suspension_notification, :designation => cites))}
        specify { @taxon_concept.destroy.should be_false }
      end
      context "when EU opinions" do
        before(:each){ create(:eu_opinion, :taxon_concept => @taxon_concept)}
        specify { @taxon_concept.destroy.should be_false }
      end
      context "when EU suspensions" do
        before(:each){ create(:eu_suspension, :taxon_concept => @taxon_concept)}
        specify { @taxon_concept.destroy.should be_false }
      end
    end
  end
end
