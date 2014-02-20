#Encoding: UTF-8
require 'spec_helper'

describe Checklist::Pdf::IndexAnnotationsKey do
  let(:en){ create(:language, :name => 'English', :iso_code1 => 'EN') }
  let(:family_tc){
    tc = create_cites_eu_family(
      :taxon_name => create(:taxon_name, :scientific_name => 'Foobaridae')
    )
    Sapi::StoredProcedures.rebuild_cites_taxonomy_and_listings
    MTaxonConcept.find(tc.id)
  }
  let(:genus_tc){
    tc = create_cites_eu_genus(
      :parent_id => family_tc.id,
      :taxon_name => create(:taxon_name, :scientific_name => 'Foobarus')
    )
    Sapi::StoredProcedures.rebuild_cites_taxonomy_and_listings
    MTaxonConcept.find(tc.id)
  }
  let(:species_tc){
    tc = create_cites_eu_species(
      :parent_id => genus_tc.id,
      :taxon_name => create(:taxon_name, :scientific_name => 'bizarrus')
    )
    Sapi::StoredProcedures.rebuild_cites_taxonomy_and_listings
    MTaxonConcept.find(tc.id)
  }
  let(:family_annotation){
    create(
      :annotation,
      :full_note_en => 'Except <i>Foobarus spp</i><p>some more stuff here</p>',
      :display_in_index => true
    )
  }
  let(:genus_annotation){
    create(
      :annotation,
      :full_note_en => 'Except <i>Foobarus bizarrus</i>',
      :display_in_index => true
    )
  }
  let(:species_annotation){
    create(
      :annotation,
      :full_note_en => 'Only populations of X, Y, Z',
      :display_in_index => true
    )
  }
  let!(:listings){
    create_cites_I_addition(
      :taxon_concept_id => family_tc.id,
      :annotation_id => family_annotation.id,
      :is_current => true
    )
    create_cites_II_addition(
      :taxon_concept_id => genus_tc.id,
      :annotation_id => genus_annotation.id,
      :is_current => true
    )
    create_cites_III_addition(
      :taxon_concept_id => species_tc.id,
      :annotation_id => species_annotation.id,
      :is_current => true
    )
    Sapi::StoredProcedures.rebuild_cites_taxonomy_and_listings
  }
  describe :annotations_key do
    subject{ Checklist::Pdf::IndexAnnotationsKey.new }
    specify{
      LatexToPdf.stub(:html2latex).and_return('x')
      subject.annotations_key.should ==  "\\parindent 0in\\cpart{Annotations key}\n\\section*{Annotations not preceded by \"\\#\"}\n\\cfbox{green}{\\superscript{1} \\textbf{FOOBARIDAE spp.}}\n\nx\n\n\\cfbox{green}{\\superscript{2} \\textbf{\\textit{Foobarus} spp.}}\n\nx\n\n\\cfbox{green}{\\superscript{3} \\textbf{\\textit{Foobarus bizarrus}}}\n\nx\n\n\\parindent -0.1in"
    }
  end

end
