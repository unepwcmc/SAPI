#Encoding: UTF-8
require 'spec_helper'

describe Checklist do 
  include_context "Pecari tajacu"

  context "search by cites populations" do
    context "when America" do
      subject{
        checklist = Checklist::Checklist.new({
          :country_ids => [america.id]
        })
        checklist.generate(0,100).taxon_concepts
      }
      specify do
        subject.should_not include(@species)
      end
    end
    context "when Mexico" do
      subject{
        checklist = Checklist::Checklist.new({
          :country_ids => [mexico.id]
        })
        checklist.generate(0,100).taxon_concepts
      }
      specify do
        subject.should_not include(@species)
      end
    end
    context "when Canada" do
      subject{
        checklist = Checklist::Checklist.new({
          :country_ids => [canada.id]
        })
        checklist.generate(0,100).taxon_concepts
      }
      specify do
        subject.should_not include(@species)
      end
    end
    context "when Argentina" do
      subject{
        checklist = Checklist::Checklist.new({
          :country_ids => [argentina.id]
        })
        checklist.generate(0,100).taxon_concepts
      }
      specify do
        subject.should include(@species)
      end
    end
    #context "when South America" do
    #  subject{
    #    checklist = Checklist::Checklist.new({
    #      :country_ids => [south_america.id]
    #    })
    #    checklist.generate(0,100).taxon_concepts
    #  }
    #  specify do
    #    subject.should include(@species)
    #  end
    #end
    context "when North America" do
      subject{
        checklist = Checklist::Checklist.new({
          :country_ids => [north_america.id]
        })
        checklist.generate(0,100).taxon_concepts
      }
      specify do
        subject.should_not include(@species)
      end
    end
    context "when North America and Argentina" do
      subject{
        checklist = Checklist::Checklist.new({
          :country_ids => [north_america.id, argentina.id]
        })
        checklist.generate(0,100).taxon_concepts
      }
      specify do
        subject.should include(@species)
      end
    end
  end
end
