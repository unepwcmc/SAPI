#Encoding: UTF-8
require 'spec_helper'

describe Checklist::Pdf::History do
  let(:en){ create(:language, :name => 'English', :iso_code1 => 'EN') }
  let(:family_tc){
    tc = create_cites_eu_family(
      :taxon_name => create(:taxon_name, :scientific_name => 'Foobaridae')
    )
    MTaxonConcept.find(tc.id)
  }
  let(:genus_tc){
    tc = create_cites_eu_genus(
      :parent_id => family_tc.id,
      :taxon_name => create(:taxon_name, :scientific_name => 'Foobarus')
    )
    MTaxonConcept.find(tc.id)
  }
  describe :higher_taxon_name do
    context "when family" do
      let(:tc){ family_tc }
      let!(:taxon_common){
        create(
          :taxon_common,
          :taxon_concept_id => tc.id,
          :common_name => create(
            :common_name,
            :name => 'Foobars',
            :language => en
          )
        )
        Sapi::rebuild(:except => [:taxonomy])
      }
      subject{ Checklist::Pdf::History.new(:scientific_name => tc.full_name, :show_english => true) }
      specify{
        subject.higher_taxon_name(tc.reload).should == "\\subsection*{FOOBARIDAE  (E) Foobars }\n"
      }
    end
  end

  describe :listed_taxon_name do
    context "when family" do
      let(:tc){ family_tc }
      let!(:lc){
        lc = create_cites_I_addition(
          :taxon_concept_id => tc.id,
          :is_current => true
        )
        Sapi::rebuild(:except => [:taxonomy])
        MListingChange.find(lc.id)
      }
      subject{ Checklist::Pdf::History.new(:scientific_name => tc.full_name) }
      specify{
        subject.listed_taxon_name(tc).should == 'FOOBARIDAE spp.'
      }
    end
    context "when genus" do
      let(:tc){ genus_tc }
      let!(:lc){
        lc = create_cites_I_addition(
          :taxon_concept_id => tc.id,
          :is_current => true
        )
        Sapi::rebuild(:except => [:taxonomy])
        MListingChange.find(lc.id)
      }
      subject{ Checklist::Pdf::History.new(:scientific_name => tc.full_name) }
      specify{
        subject.listed_taxon_name(tc).should == '\textit{Foobarus} spp.'
      }
    end
  end

  describe :annotation_for_language do
    let(:tc){ family_tc }
    let!(:lc){
      lc = create_cites_I_addition(
        :taxon_concept_id => tc.id,
        :annotation_id => annotation.id,
        :is_current => true
      )
      Sapi::rebuild(:except => [:taxonomy])
      MListingChange.find(lc.id)
    }
    context "annotations with italics" do
      let(:annotation){
        create(
          :annotation,
          :short_note_en => 'Except <i>Foobarus cracoviensis</i> and <i>Foobarus cambridgianus</i>'
        )
      }
      subject{ Checklist::Pdf::History.new(:scientific_name => tc.full_name) }
      specify{
        subject.annotation_for_language(lc, 'en').should ==
        'Except \textit{Foobarus cracoviensis} and \textit{Foobarus cambridgianus}'
      }
    end
    context "annotations with italics and latex special characters" do
      let(:annotation){
        create(
          :annotation,
          :short_note_en => 'Except <i>Foobarus cracoviensis</i> as defined by Karl & Bernard'
        )
      }
      subject{ Checklist::Pdf::History.new(:scientific_name => tc.full_name) }
      specify{
        subject.annotation_for_language(lc, 'en').should ==
        'Except \textit{Foobarus cracoviensis} as defined by Karl \& Bernard'
      }
    end
    context "annotations with footnotes" do
      let(:annotation){
        create(
          :annotation,
          :short_note_en => 'Except <i>Foobarus cracoviensis</i>',
          :full_note_en => 'They have plenty of <i>Foobarus cracoviensis</i> in Kraków',
          :display_in_footnote => true
        )
      }
      subject{ Checklist::Pdf::History.new(:scientific_name => tc.full_name) }
      specify{
        subject.annotation_for_language(lc, 'en').should ==
        'Except \textit{Foobarus cracoviensis}\footnote{They have plenty of \textit{Foobarus cracoviensis} in Kraków}'
      }
    end
  end
end
