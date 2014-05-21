# == Schema Information
#
# Table name: common_names
#
#  id            :integer          not null, primary key
#  name          :string(255)      not null
#  language_id   :integer          not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  created_by_id :integer
#  updated_by_id :integer
#

require 'spec_helper'

describe CommonName do
  context "Generating PDF" do
    describe :english_to_pdf do
      it "should print last word before the first word, separated by comma" do
        CommonName.english_to_pdf("Grey Wolf").should == "Wolf, Grey"
      end
      it "should print the last word before the other words, separated by comma" do
        CommonName.english_to_pdf("Northern Rock Mountain Wolf").should == "Wolf, Northern Rock Mountain"
      end
      it "should print the single word, if the common name is composed of only one word" do
        CommonName.english_to_pdf("Wolf").should == "Wolf"
      end
    end
  end
end
