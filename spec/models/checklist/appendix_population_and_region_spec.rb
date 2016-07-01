require 'spec_helper'

describe Checklist do
  include_context "Pecari tajacu"

  context "search by cites populations" do
    context "when America" do
      subject {
        checklist = Checklist::Checklist.new({
          :country_ids => [america.id]
        })
        checklist.results
      }
      specify do
        subject.should_not include(@species)
      end
    end
    context "when Mexico" do
      subject {
        checklist = Checklist::Checklist.new({
          :country_ids => [mexico.id]
        })
        checklist.results
      }
      specify do
        subject.should_not include(@species)
      end
    end
    context "when Canada" do
      subject {
        checklist = Checklist::Checklist.new({
          :country_ids => [canada.id]
        })
        checklist.results
      }
      specify do
        subject.should_not include(@species)
      end
    end
    context "when Argentina" do
      subject {
        checklist = Checklist::Checklist.new({
          :country_ids => [argentina.id]
        })
        checklist.results
      }
      specify do
        subject.should include(@species)
      end
    end
    context "when South America" do
      subject {
        checklist = Checklist::Checklist.new({
          :cites_region_ids => [south_america.id]
        })
        checklist.results
      }
      specify do
        subject.should include(@species)
      end
    end
    context "when North America" do
      subject {
        checklist = Checklist::Checklist.new({
          :cites_region_ids => [north_america.id]
        })
        checklist.results
      }
      specify do
        subject.should_not include(@species)
      end
    end
    context "when North America and Argentina" do
      subject {
        checklist = Checklist::Checklist.new({
          :cites_region_ids => [north_america.id],
          :country_ids => [argentina.id]
        })
        checklist.results
      }
      specify do
        subject.should include(@species)
      end
    end
  end
end
