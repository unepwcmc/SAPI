require 'spec_helper'

describe Checklist::Pdf::HistoryAnnotationsKey do
  let(:en) { create(:language, :name => 'English', :iso_code1 => 'EN') }

  describe :annotations_key do
    subject { Checklist::Pdf::HistoryAnnotationsKey.new }
    specify {
      subject.stub(:non_hash_annotations_key).and_return('x')
      subject.stub(:hash_annotations_key).and_return('x')
      subject.annotations_key.should == "\\newpage\n\\parindent 0in\\cpart{\\historicalSummaryOfAnnotations}\nx\\parindent -0.1in"
    }
  end

  describe :hash_annotations_key do
    before(:each) do
      plant_genus = create_cites_eu_genus(
        :taxon_name => create(:taxon_name, :scientific_name => 'Foobaria'),
        :parent => create_cites_eu_family(
          :parent => create_cites_eu_order(
            :parent => cites_eu_plantae
          )
        )
      )
      plant_species = create_cites_eu_species(
        :parent_id => plant_genus.id,
        :taxon_name => create(:taxon_name, :scientific_name => 'curiosa')
      )
      create_cites_I_addition(
        :taxon_concept_id => plant_species.id,
        :hash_annotation => create(
          :annotation,
          :event => create_cites_cop(
            :name => 'CoP1',
            :is_current => false,
            :effective_at => '2012-07-01'
          ),
          :symbol => '#1',
          :full_note_en => 'Only trunks'
        )
      )
      create_cites_I_addition(
        :taxon_concept_id => plant_species.id,
        :hash_annotation => create(
          :annotation,
          :event => create_cites_cop(
            :name => 'CoP2',
            :is_current => true,
            :effective_at => '2013-07-01'
          ),
          :symbol => '#1',
          :full_note_en => 'Only bark'
        ),
        :is_current => true
      )
      Sapi::StoredProcedures.rebuild_cites_taxonomy_and_listings
    end
    subject { Checklist::Pdf::HistoryAnnotationsKey.new }
    specify {
      subject.hash_annotations_key.should == "\\hashAnnotationsHistoryInfo\n\n\\hashannotationstable{\n\\rowcolor{pale_aqua}\nCoP1 & \\validFrom \\hspace{2 pt} 01/07/2012\\\\\n\\#1 & Only trunks \\\\\n\n}\n\\hashannotationstable{\n\\rowcolor{pale_aqua}\nCoP2 & \\validFrom \\hspace{2 pt} 01/07/2013\\\\\n\\#1 & Only bark \\\\\n\n}\n"
    }
  end

end
