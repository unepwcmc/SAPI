require 'spec_helper'

describe Checklist::Pdf::History do
  let(:en) { create(:language, :name => 'English', :iso_code1 => 'EN') }
  let!(:fr) { create(:language, :name => 'French', :iso_code1 => 'FR') }
  let!(:es) { create(:language, :name => 'Spanish', :iso_code1 => 'ES') }
  let(:family_tc) {
    tc = create_cites_eu_family(
      :taxon_name => create(:taxon_name, :scientific_name => 'Foobaridae')
    )
    Sapi::StoredProcedures.rebuild_cites_taxonomy_and_listings
    MTaxonConcept.find(tc.id)
  }
  let(:genus_tc) {
    tc = create_cites_eu_genus(
      :parent_id => family_tc.id,
      :taxon_name => create(:taxon_name, :scientific_name => 'Foobarus')
    )
    Sapi::StoredProcedures.rebuild_cites_taxonomy_and_listings
    MTaxonConcept.find(tc.id)
  }
  describe :higher_taxon_name do
    context "when family" do
      let(:tc) { family_tc }
      let!(:taxon_common) {
        create(
          :taxon_common,
          :taxon_concept_id => tc.id,
          :common_name => create(
            :common_name,
            :name => 'Foobars',
            :language => en
          )
        )
        Sapi::StoredProcedures.rebuild_cites_taxonomy_and_listings
      }
      subject { Checklist::Pdf::History.new(:scientific_name => tc.full_name, :show_english => true) }
      specify {
        subject.higher_taxon_name(tc.reload).should == "\\subsection*{FOOBARIDAE  (E) Foobars }\n"
      }
    end
  end

  describe :listed_taxon_name do
    context "when family" do
      let(:tc) { family_tc }
      let!(:lc) {
        lc = create_cites_I_addition(
          :taxon_concept_id => tc.id,
          :is_current => true
        )
        Sapi::StoredProcedures.rebuild_cites_taxonomy_and_listings
        MCitesListingChange.find(lc.id)
      }
      subject { Checklist::Pdf::History.new(:scientific_name => tc.full_name) }
      specify {
        subject.listed_taxon_name(tc).should == 'FOOBARIDAE spp.'
      }
    end
    context "when genus" do
      let(:tc) { genus_tc }
      let!(:lc) {
        lc = create_cites_I_addition(
          :taxon_concept_id => tc.id,
          :is_current => true
        )
        Sapi::StoredProcedures.rebuild_cites_taxonomy_and_listings
        MCitesListingChange.find(lc.id)
      }
      subject { Checklist::Pdf::History.new(:scientific_name => tc.full_name) }
      specify {
        subject.listed_taxon_name(tc).should == '\emph{Foobarus} spp.'
      }
    end
  end

  describe :annotation_for_language do
    context "annotation with footnote" do
      let(:annotation) {
        create(
          :annotation,
          :short_note_en => 'Except <i>Foobarus cracoviensis</i>',
          :full_note_en => '...',
          :display_in_footnote => true
        )
      }
      let(:tc) { genus_tc }
      let(:lc) {
        lc = create_cites_I_addition(
          :taxon_concept_id => tc.id,
          :annotation_id => annotation.id,
          :is_current => true,
          :nomenclature_note_en => 'Previously listed as <i>Foobarus polonicus</i>.'
        )
        Sapi::StoredProcedures.rebuild_cites_taxonomy_and_listings
        MCitesListingChange.find(lc.id)
      }
      subject { Checklist::Pdf::History.new({}) }
      specify {
        subject.annotation_for_language(lc, 'en').should == "Except \\textit{Foobarus cracoviensis}\n\nPreviously listed as \\textit{Foobarus polonicus}.\\footnote{...}"
      }
    end
  end
end
