require 'spec_helper'

describe Checklist::Pdf::IndexAnnotationsKey do
  let(:en) { create(:language, :name => 'English', :iso_code1 => 'EN') }

  describe :annotations_key do
    subject { Checklist::Pdf::IndexAnnotationsKey.new }
    specify {
      subject.stub(:non_hash_annotations_key).and_return('x')
      subject.stub(:hash_annotations_key).and_return('x')
      subject.annotations_key.should == "\\newpage\n\\parindent 0in\\cpart{\\annotationsKey}\nxx\\parindent -0.1in"
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
    subject { Checklist::Pdf::IndexAnnotationsKey.new }
    specify {
      subject.hash_annotations_key.should == "\\newpage\n\\section*{\\hashAnnotations}\n\\hashAnnotationsIndexInfo\n\n\\hashannotationstable{\n\\rowcolor{pale_aqua}\nCoP2 & \\validFrom \\hspace{2 pt} 01/07/2013\\\\\n\\#1 & Only bark \\\\\n\n}\n"
    }
  end

  describe :non_hash_annotations_key do
    before(:each) do
      animal_genus = create_cites_eu_genus(
        :taxon_name => create(:taxon_name, :scientific_name => 'Foobarus'),
        :parent => create_cites_eu_family(
          :parent => create_cites_eu_order(
            :parent => cites_eu_mammalia
          )
        )
      )
      animal_species = create_cites_eu_species(
        :parent_id => animal_genus.id,
        :taxon_name => create(:taxon_name, :scientific_name => 'bizarrus')
      )
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
        :annotation => create(
          :annotation,
          :symbol => nil,
          :parent_symbol => nil,
          :full_note_en => 'Only populations of PL',
          :display_in_index => true
        ),
        :is_current => true
      )
      create_cites_II_addition(
        :taxon_concept_id => animal_species.id,
        :annotation => create(
          :annotation,
          :symbol => nil,
          :parent_symbol => nil,
          :full_note_en => 'Except <i>Foobarus bizarrus nonsensus</i>',
          :display_in_index => true
        ),
        :is_current => true
      )
      Sapi::StoredProcedures.rebuild_cites_taxonomy_and_listings
    end
    subject { Checklist::Pdf::IndexAnnotationsKey.new }
    specify {
      LatexToPdf.stub(:html2latex).and_return('x')
      subject.non_hash_annotations_key.should == "\\section*{\\nonHashAnnotations}\n\\cfbox{orange}{\\superscript{1} \\textbf{\\textit{Foobarus bizarrus}}}\n\nx\n\n\\cfbox{green}{\\superscript{2} \\textbf{\\textit{Foobaria curiosa}}}\n\nx\n\n"
    }
  end

end
