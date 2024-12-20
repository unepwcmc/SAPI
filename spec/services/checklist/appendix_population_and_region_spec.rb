require 'spec_helper'

describe Checklist do
  include_context 'Pecari tajacu'

  context 'search by cites populations' do
    context 'when America' do
      subject do
        checklist = Checklist::Checklist.new(
          {
            country_ids: [ america.id ]
          }
        )
        checklist.results
      end
      specify do
        expect(subject).not_to include(@species)
      end
    end
    context 'when Mexico' do
      subject do
        checklist = Checklist::Checklist.new(
          {
            country_ids: [ mexico.id ]
          }
        )
        checklist.results
      end
      specify do
        expect(subject).not_to include(@species)
      end
    end
    context 'when Canada' do
      subject do
        checklist = Checklist::Checklist.new(
          {
            country_ids: [ canada.id ]
          }
        )
        checklist.results
      end
      specify do
        expect(subject).not_to include(@species)
      end
    end
    context 'when Argentina' do
      subject do
        checklist = Checklist::Checklist.new(
          {
            country_ids: [ argentina.id ]
          }
        )
        checklist.results
      end
      specify do
        expect(subject).to include(@species)
      end
    end
    context 'when South America' do
      subject do
        checklist = Checklist::Checklist.new(
          {
            cites_region_ids: [ south_america.id ]
          }
        )
        checklist.results
      end
      specify do
        expect(subject).to include(@species)
      end
    end
    context 'when North America' do
      subject do
        checklist = Checklist::Checklist.new(
          {
            cites_region_ids: [ north_america.id ]
          }
        )
        checklist.results
      end
      specify do
        expect(subject).not_to include(@species)
      end
    end
    context 'when North America and Argentina' do
      subject do
        checklist = Checklist::Checklist.new(
          {
            cites_region_ids: [ north_america.id ],
            country_ids: [ argentina.id ]
          }
        )
        checklist.results
      end
      specify do
        expect(subject).to include(@species)
      end
    end
  end
end
