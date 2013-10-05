#Encoding: UTF-8
require 'spec_helper'

describe Checklist do
  include_context "Psittaciformes"

  context "when filtering by appendix" do
    before(:each){ Sapi.rebuild }
    context "I" do
      subject {
        Checklist::Checklist.new({
          :cites_appendices => ['I']
        }).results
      }
      specify "for Cacatua goffiniana" do
        subject.select{ |e| e.full_name == 'Cacatua goffiniana' }.first.should_not be_nil
      end

      specify "for Agapornis roseicollis" do
        subject.select{ |e| e.full_name == 'Agapornis roseicollis' }.first.should be_nil
      end
    end

  end
end