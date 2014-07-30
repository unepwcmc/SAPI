#Encoding: UTF-8
require 'spec_helper'

describe Checklist::Pdf::Index do
  let(:family_tc){
    create_cites_eu_family(
      parent: create_cites_eu_order(parent: cites_eu_plantae),
      taxon_name: create(:taxon_name, scientific_name: 'Foobaridae')
    )
  }
  let(:genus_tc){
    create_cites_eu_genus(
      parent:  family_tc,
      taxon_name:  create(:taxon_name, scientific_name:  'Foobarus')
    )
  }
  let(:species_tc){
    create_cites_eu_species(
      parent:genus_tc,
      taxon_name:  create(:taxon_name, scientific_name:  'bizarrus')
    )
  }

  describe :annotations_key do
    before(:each) do
      create_cites_I_addition(
        taxon_concept:  family_tc,
        annotation:  create(
          :annotation,
          full_note_en:  'Except <i>Foobarus spp</i><p>some more stuff here</p>',
          display_in_index:  true
        ),
        is_current:  true
      )
      create_cites_II_addition(
        taxon_concept:  genus_tc,
        annotation:  create(
          :annotation,
          full_note_en:  'Except <i>Foobarus bizarrus</i>',
          display_in_index:  true
        ),
        is_current:  true
      )
      create_cites_III_addition(
        taxon_concept:  species_tc,
        annotation:  create(
          :annotation,
          full_note_en:  'Only populations of X, Y, Z',
          display_in_index:  true
        ),
        is_current:  true
      )
      Sapi::StoredProcedures.rebuild_cites_taxonomy_and_listings
    end
    subject{ Checklist::Pdf::Index.new({}) }
    specify{
      LatexToPdf.stub(:html2latex).and_return('x')
      subject.annotations_key.should ==  "\\parindent 0in\\cpart{Annotations key}\n\\section*{Annotations not preceded by \"\\#\"}\n\\cfbox{green}{\\superscript{1} \\textbf{FOOBARIDAE spp.}}\n\nx\n\n\\cfbox{green}{\\superscript{2} \\textbf{\\textit{Foobarus} spp.}}\n\nx\n\n\\cfbox{green}{\\superscript{3} \\textbf{\\textit{Foobarus bizarrus}}}\n\nx\n\n\\parindent -0.1in"
    }
  end

end
