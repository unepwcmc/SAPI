require 'spec_helper'

describe Checklist do
  include_context 'Psittaciformes'

  context 'when filtering by appendix' do
    context 'I' do
      before(:all) do
        @checklist = Checklist::Checklist.new(
          {
            cites_appendices: [ 'I' ]
          }
        )
        @taxon_concepts = @checklist.results
      end
      it 'should return Cacatua goffiniana' do
        expect(@taxon_concepts.select { |e| e.full_name == @species1_2_1.full_name }.first).not_to be_nil
      end

      it 'should not return Agapornis roseicollis' do
        expect(@taxon_concepts.select { |e| e.full_name == @species2_1.full_name }.first).to be_nil
      end
    end
  end
end
