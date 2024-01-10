require 'spec_helper'
describe DocumentSearch, sidekiq: :inline do
  describe :results do
    let(:meliaceae) {
      create_cites_eu_family(
        taxon_name: create(:taxon_name, scientific_name: 'Meliaceae')
      )
    }
    let(:swietenia_macrophylla) {
      create_cites_eu_species(
        taxon_name: create(:taxon_name, scientific_name: 'Swietenia macrophylla'),
        parent: create_cites_eu_genus(
          taxon_name: create(:taxon_name, scientific_name: 'Swietenia'),
          parent: meliaceae
        )
      )
    }
    let(:cedrela_odorata) {
      create_cites_eu_species(
        taxon_name: create(:taxon_name, scientific_name: 'Cedrela odorata'),
        parent: create_cites_eu_genus(
          taxon_name: create(:taxon_name, scientific_name: 'Cedrela'),
          parent: meliaceae
        )
      )
    }
    let(:belize) {
      create(
        :geo_entity,
        geo_entity_type: country_geo_entity_type,
        name: 'Belize',
        iso_code2: 'BZ'
      )
    }
    let(:brazil) {
      create(
        :geo_entity,
        geo_entity_type: country_geo_entity_type,
        name: 'Brazil',
        iso_code2: 'BR'
      )
    }
    let(:document_on_swietenia) {
      document = create(
        :proposal,
        is_public: true,
        event: create(:cites_cop, designation: cites),
        title: 'Document on Swietenia',
        sort_index: 1
      )
      citation = create(
        :document_citation, document_id: document.id
      )
      create(
        :document_citation_taxon_concept,
        document_citation_id: citation.id,
        taxon_concept_id: swietenia_macrophylla.id
      )
      document
    }
    let(:document_on_swietenia_in_belize) {
      document = create(
        :proposal, is_public: true,
        event: create(:cites_cop, designation: cites),
        title: 'Document on Swietenia in Belize',
        sort_index: 2
      )
      citation = create(
        :document_citation, document_id: document.id
      )
      create(
        :document_citation_taxon_concept,
        document_citation_id: citation.id,
        taxon_concept_id: swietenia_macrophylla.id
      )
      create(
        :document_citation_geo_entity,
        document_citation_id: citation.id,
        geo_entity_id: belize.id
      )
      document
    }
    let(:document_on_swietenia_in_brazil) {
      document = create(
        :proposal, is_public: true,
        event: create(:cites_cop, designation: cites),
        title: 'Document on Swietenia in Brazil',
        sort_index: 3
      )
      citation = create(
        :document_citation, document_id: document.id
      )
      create(
        :document_citation_taxon_concept,
        document_citation_id: citation.id,
        taxon_concept_id: swietenia_macrophylla.id
      )
      create(
        :document_citation_geo_entity,
        document_citation_id: citation.id,
        geo_entity_id: brazil.id
      )
      document
    }
    let(:document_on_swietenia_in_belize_and_brazil) {
      document = create(
        :proposal, is_public: true,
        event: create(:cites_cop, designation: cites),
        title: 'Document on Swietenia in Belize and Brazil',
        sort_index: 4
      )
      citation = create(
        :document_citation, document_id: document.id
      )
      create(
        :document_citation_taxon_concept,
        document_citation_id: citation.id,
        taxon_concept_id: swietenia_macrophylla.id
      )
      create(
        :document_citation_geo_entity,
        document_citation_id: citation.id,
        geo_entity_id: belize.id
      )
      create(
        :document_citation_geo_entity,
        document_citation_id: citation.id,
        geo_entity_id: brazil.id
      )
      document
    }
    let(:document_on_swietenia_in_belize_and_cedrela_in_brazil) {
      document = create(
        :proposal, is_public: true,
        event: create(:cites_cop, designation: cites),
        title: 'Document on Swietenia in Belize and Cedrela in Brazil',
        sort_index: 5
      )
      citation1 = create(
        :document_citation, document_id: document.id
      )
      create(
        :document_citation_taxon_concept,
        document_citation_id: citation1.id,
        taxon_concept_id: swietenia_macrophylla.id
      )
      create(
        :document_citation_geo_entity,
        document_citation_id: citation1.id,
        geo_entity_id: belize.id
      )
      citation2 = create(
        :document_citation, document_id: document.id
      )
      create(
        :document_citation_taxon_concept,
        document_citation_id: citation2.id,
        taxon_concept_id: cedrela_odorata.id
      )
      create(
        :document_citation_geo_entity,
        document_citation_id: citation2.id,
        geo_entity_id: brazil.id
      )
      document
    }
    let(:document_on_brazil) {
      document = create(
        :proposal, is_public: true,
        event: create(:cites_cop, designation: cites),
        title: 'Document on Brazil',
        sort_index: 6
      )
      citation = create(
        :document_citation, document_id: document.id
      )
      create(
        :document_citation_geo_entity,
        document_citation_id: citation.id,
        geo_entity_id: brazil.id
      )
      document
    }
    let(:document_without_citations) {
      document = create(
        :proposal, is_public: true,
        event: create(:cites_cop, designation: cites),
        title: 'Document without citations',
        sort_index: 7
      )
    }

    before(:each) do
      document_on_swietenia
      document_on_swietenia_in_belize
      document_on_swietenia_in_brazil
      document_on_swietenia_in_belize_and_brazil
      document_on_swietenia_in_belize_and_cedrela_in_brazil
      document_on_brazil
      document_without_citations
      DocumentSearch.refresh_citations_and_documents
    end

    context "when searching by Swietenia macrophylla" do
      subject {
        DocumentSearch.new(
          {
            'taxon_concepts_ids' => [swietenia_macrophylla.id]
          },
          'admin'
        ).results
      }
      specify {
        expect(subject.map(&:id).sort).to eq(
          [
            document_on_swietenia,
            document_on_swietenia_in_belize,
            document_on_swietenia_in_brazil,
            document_on_swietenia_in_belize_and_brazil,
            document_on_swietenia_in_belize_and_cedrela_in_brazil
          ].map(&:id).sort
        )
      }
    end

    context "when searching by Brazil" do
      subject {
        DocumentSearch.new(
          {
            'geo_entities_ids' => [brazil.id]
          },
          'admin'
        ).results
      }
      specify {
        expect(subject.map(&:id).sort).to eq(
          [
            document_on_swietenia_in_brazil,
            document_on_swietenia_in_belize_and_brazil,
            document_on_swietenia_in_belize_and_cedrela_in_brazil,
            document_on_brazil
          ].map(&:id).sort
        )
      }
    end

    context "when searching by Swietenia macrophylla in Brazil" do
      subject {
        DocumentSearch.new(
          {
            'taxon_concepts_ids' => [swietenia_macrophylla.id],
            'geo_entities_ids' => [brazil.id]
          },
          'admin'
        ).results
      }
      specify {
        expect(subject.map(&:id).sort).to eq(
          [
            document_on_swietenia_in_brazil,
            document_on_swietenia_in_belize_and_brazil
          ].map(&:id).sort
        )
      }
    end

    context "when searching by Swietenia macrophylla in Brazil and Belize" do
      subject {
        DocumentSearch.new(
          {
            'taxon_concepts_ids' => [swietenia_macrophylla.id],
            'geo_entities_ids' => [brazil.id, belize.id]
          },
          'admin'
        ).results
      }
      specify {
        expect(subject.map(&:id).sort).to eq(
          [
            document_on_swietenia_in_belize,
            document_on_swietenia_in_brazil,
            document_on_swietenia_in_belize_and_brazil,
            document_on_swietenia_in_belize_and_cedrela_in_brazil
          ].map(&:id).sort
        )
      }
    end

  end

  describe :documents_need_refreshing? do
    before(:each) do
      @d = nil
      Timecop.travel(Time.now - (DocumentSearch::REFRESH_INTERVAL + 1).minutes) do
        @d = create(:proposal)
        DocumentSearch.refresh_citations_and_documents
      end
    end
    context "when no changes in last #{DocumentSearch::REFRESH_INTERVAL} minutes" do
      specify { expect(DocumentSearch.documents_need_refreshing?).to be_falsey }
    end
    context "when document created in last #{DocumentSearch::REFRESH_INTERVAL} minutes" do
      specify do
        Timecop.travel(Time.now - (DocumentSearch::REFRESH_INTERVAL - 1).minutes) do
          create(:proposal)
        end
        expect(DocumentSearch.documents_need_refreshing?).to be_truthy
      end
    end
    context "when document destroyed in last #{DocumentSearch::REFRESH_INTERVAL} minutes" do
      specify do
        Timecop.travel(Time.now - (DocumentSearch::REFRESH_INTERVAL - 1).minutes) do
          @d.destroy
        end
        expect(DocumentSearch.documents_need_refreshing?).to be_truthy
      end
    end
    context "when document updated in last #{DocumentSearch::REFRESH_INTERVAL} minutes" do
      specify do
        Timecop.travel(Time.now - (DocumentSearch::REFRESH_INTERVAL - 1).minutes) do
          @d.update_attributes(is_public: true)
        end
        expect(DocumentSearch.documents_need_refreshing?).to be_truthy
      end
    end
  end

  describe :citations_need_refreshing? do
    before(:each) do
      @d = nil
      Timecop.travel(Time.now - (DocumentSearch::REFRESH_INTERVAL + 1).minutes) do
        @d = create(:proposal)
        @c = create(:document_citation, document: @d)
        @c_tc = create(:document_citation_taxon_concept, document_citation: @c)
        DocumentSearch.refresh_citations_and_documents
      end
    end
    context "when no changes in last #{DocumentSearch::REFRESH_INTERVAL} minutes" do
      specify { expect(DocumentSearch.citations_need_refreshing?).to be_falsey }
    end
    context "when citation created in last #{DocumentSearch::REFRESH_INTERVAL} minutes" do
      specify do
        Timecop.travel(Time.now - (DocumentSearch::REFRESH_INTERVAL - 1).minutes) do
          create(:document_citation_taxon_concept, document_citation: @c)
        end
        expect(DocumentSearch.citations_need_refreshing?).to be_truthy
      end
    end
    context "when citation destroyed in last #{DocumentSearch::REFRESH_INTERVAL} minutes" do
      specify do
        Timecop.travel(Time.now - (DocumentSearch::REFRESH_INTERVAL - 1).minutes) do
          @c_tc.destroy
        end
        expect(DocumentSearch.citations_need_refreshing?).to be_truthy
      end
    end
    context "when citation updated in last #{DocumentSearch::REFRESH_INTERVAL} minutes" do
      specify do
        Timecop.travel(Time.now - (DocumentSearch::REFRESH_INTERVAL - 1).minutes) do
          @c_tc.update_attributes(taxon_concept_id: create_cites_eu_species.id)
        end
        expect(DocumentSearch.citations_need_refreshing?).to be_truthy
      end
    end
  end
end
