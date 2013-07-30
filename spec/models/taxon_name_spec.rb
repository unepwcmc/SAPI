# == Schema Information
#
# Table name: taxon_names
#
#  id              :integer          not null, primary key
#  scientific_name :string(255)      not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

require 'spec_helper'

describe TaxonName do

  describe :lower_bound do
    it "should return an empty string when parameter is an empty string" do
      TaxonName.lower_bound("").should == ""
    end
    it "should return a capitalised string when parameter is a normal string in any case" do
      TaxonName.lower_bound("AAA").should == "Aaa"
      TaxonName.lower_bound("aaa").should == "Aaa"
      TaxonName.lower_bound("AaA").should == "Aaa"
      TaxonName.lower_bound("aAa").should == "Aaa"
    end
    it "should return a capitalised string with no trailing spaces when parameter is a string with trailling spaces" do
      TaxonName.lower_bound(" AAA").should == "Aaa"
      TaxonName.lower_bound("aaa ").should == "Aaa"
    end
  end
  describe :upper_bound do
    it "should return empty string when parameter is an empty string" do
      TaxonName.upper_bound("").should == ""
    end
    it "should return a string bigger than the provided string by one character" do
      TaxonName.upper_bound("Aaa").should == "Aab"
      TaxonName.upper_bound("Bbb").should == "Bbc"
    end
    it "should return empty when a long empty string is passed" do
      TaxonName.upper_bound("    ").should == ""
    end
  end
end

