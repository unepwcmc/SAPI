require 'spec_helper'
describe DocumentSearch, sidekiq: :inline do
  describe :results do
    let(:meliaceae) do
      create_cites_eu_family(
        taxon_name: create(:taxon_name, scientific_name: 'Meliaceae')
      )
    end
    let(:swietenia_macrophylla) do
      create_cites_eu_species(
        taxon_name: create(:taxon_name, scientific_name: 'Swietenia macrophylla'),
        parent: create_cites_eu_genus(
          taxon_name: create(:taxon_name, scientific_name: 'Swietenia'),
          parent: meliaceae
        )
      )
    end
    let(:cedrela_odorata) do
      create_cites_eu_species(
        taxon_name: create(:taxon_name, scientific_name: 'Cedrela odorata'),
        parent: create_cites_eu_genus(
          taxon_name: create(:taxon_name, scientific_name: 'Cedrela'),
          parent: meliaceae
        )
      )
    end
    let(:belize) do
      create(
        :geo_entity,
        geo_entity_type: country_geo_entity_type,
        name: 'Belize',
        iso_code2: 'BZ'
      )
    end
    let(:brazil) do
      create(
        :geo_entity,
        geo_entity_type: country_geo_entity_type,
        name: 'Brazil',
        iso_code2: 'BR'
      )
    end
    let(:document_on_swietenia) do
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
    end
    let(:document_on_swietenia_in_belize) do
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
    end
    let(:document_on_swietenia_in_brazil) do
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
    end
    let(:document_on_swietenia_in_belize_and_brazil) do
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
    end
    let(:document_on_swietenia_in_belize_and_cedrela_in_brazil) do
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
    end
    let(:document_on_brazil) do
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
    end
    let(:document_without_citations) do
      document = create(
        :proposal, is_public: true,
        event: create(:cites_cop, designation: cites),
        title: 'Document without citations',
        sort_index: 7
      )
    end

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

    context 'when searching by Swietenia macrophylla' do
      subject do
        DocumentSearch.new(
          {
            'taxon_concepts_ids' => [ swietenia_macrophylla.id ]
          },
          'admin'
        ).results
      end
      specify do
        expect(subject.pluck('id').sort).to eq(
          [
            document_on_swietenia,
            document_on_swietenia_in_belize,
            document_on_swietenia_in_brazil,
            document_on_swietenia_in_belize_and_brazil,
            document_on_swietenia_in_belize_and_cedrela_in_brazil
          ].map(&:id).sort
        )
      end
    end

    context 'when searching by Brazil' do
      subject do
        DocumentSearch.new(
          {
            'geo_entities_ids' => [ brazil.id ]
          },
          'admin'
        ).results
      end
      specify do
        expect(subject.pluck('id').sort).to eq(
          [
            document_on_swietenia_in_brazil,
            document_on_swietenia_in_belize_and_brazil,
            document_on_swietenia_in_belize_and_cedrela_in_brazil,
            document_on_brazil
          ].map(&:id).sort
        )
      end
    end

    context 'when searching by Swietenia macrophylla in Brazil' do
      subject do
        DocumentSearch.new(
          {
            'taxon_concepts_ids' => [ swietenia_macrophylla.id ],
            'geo_entities_ids' => [ brazil.id ]
          },
          'admin'
        ).results
      end
      specify do
        expect(subject.pluck('id').sort).to eq(
          [
            document_on_swietenia_in_brazil,
            document_on_swietenia_in_belize_and_brazil
          ].map(&:id).sort
        )
      end
    end

    context 'when searching by Swietenia macrophylla in Brazil and Belize' do
      subject do
        DocumentSearch.new(
          {
            'taxon_concepts_ids' => [ swietenia_macrophylla.id ],
            'geo_entities_ids' => [ brazil.id, belize.id ]
          },
          'admin'
        ).results
      end
      specify do
        expect(subject.pluck('id').sort).to eq(
          [
            document_on_swietenia_in_belize,
            document_on_swietenia_in_brazil,
            document_on_swietenia_in_belize_and_brazil,
            document_on_swietenia_in_belize_and_cedrela_in_brazil
          ].map(&:id).sort
        )
      end
    end
  end

  describe :documents_need_refreshing? do
    # Where DocumentSearch::REFRESH_INTERVAL is 5,
    #
    # - @d is a Document::Proposal created 6 minutes ago
    # - refresh_citations_and_documents has been run, so api_documents_mview
    #   should be up-to-date.
    #
    # In these tests we will check that making changes to @d 4 minutes ago
    # causes documents_need_refreshing to become true.

    before(:each) do
      @d = nil

      travel_to(Time.now - (DocumentSearch::REFRESH_INTERVAL + 1).minutes) do
        @d = create(:proposal)
        DocumentSearch.refresh_citations_and_documents
      end
    end

    context "when no changes in last #{DocumentSearch::REFRESH_INTERVAL} minutes" do
      specify { expect(DocumentSearch.documents_need_refreshing?).to be_falsey }
    end

    context "when document created in last #{DocumentSearch::REFRESH_INTERVAL} minutes" do
      specify do
        travel_to(Time.now - (DocumentSearch::REFRESH_INTERVAL - 1).minutes) do
          create(:proposal)
        end

        expect(DocumentSearch.documents_need_refreshing?).to be_truthy
      end
    end

    context "when document destroyed in last #{DocumentSearch::REFRESH_INTERVAL} minutes" do
      specify do
        travel_to(Time.now - (DocumentSearch::REFRESH_INTERVAL - 1).minutes) do
          @d.destroy
        end

        expect(DocumentSearch.documents_need_refreshing?).to be_truthy
      end
    end

    context "when document updated in last #{DocumentSearch::REFRESH_INTERVAL} minutes" do
      specify do
        travel_to(Time.now - (DocumentSearch::REFRESH_INTERVAL - 1).minutes) do
          @d.update!(is_public: true)
        end

        expect(DocumentSearch.documents_need_refreshing?).to be_truthy
      end
    end
  end

  describe :citations_need_refreshing? do
    # Where DocumentSearch::REFRESH_INTERVAL is 5,
    #
    # - @refresh_threshold is 5 minutes ago
    # - @recent_time is 4 minutes ago
    # - @d is a Document::Proposal created 6 minutes ago, as are the following:
    # - @c is a DocumentCitation, belonging to @d
    # - @c_tc is a DocumentCitationTaxonConcept belonging to @c
    # - @c_ge is a DocumentCitationGeoEntity belonging to @c
    # - refresh_citations_and_documents has been run, so api_documents_mview
    #   should be up-to-date.
    #
    # In these tests we will check that making changes 4 minutes ago to any of
    # the models which depend directly or indirectly on the Document model will
    # cause documents_need_refreshing to become true, by amending the attribute
    # updated_at on @c and @d

    before(:each) do
      @refresh_threshold = Time.now - (DocumentSearch::REFRESH_INTERVAL).minutes
      @recent_time = Time.now - (DocumentSearch::REFRESH_INTERVAL - 1).minutes

      @d = nil

      @ge2 = create(
        :geo_entity,
        geo_entity_type: country_geo_entity_type,
        name: 'Brazil',
        iso_code2: 'BR'
      )

      travel_to(Time.now - (DocumentSearch::REFRESH_INTERVAL + 1).minutes) do
        @d = create(:proposal)
        @c = create(:document_citation, document: @d)
        @c_tc = create(:document_citation_taxon_concept, document_citation: @c)
        @c_ge = create(:document_citation_geo_entity, document_citation: @c)

        DocumentSearch.refresh_citations_and_documents
      end
    end

    context "when no changes in last #{DocumentSearch::REFRESH_INTERVAL} minutes" do
      specify do
        expect(@c.reload.updated_at).to be < @refresh_threshold
        expect(@d.reload.updated_at).to be < @refresh_threshold

        expect(DocumentSearch.citations_need_refreshing?).to be_falsey
      end
    end

    context 'when DocumentCitation' do
      context "created in last #{DocumentSearch::REFRESH_INTERVAL} minutes" do
        specify do
          travel_to(@recent_time) do
            create(:document_citation, document: @d)
          end

          expect(@d.reload.updated_at).to be > @refresh_threshold
          expect(DocumentSearch.citations_need_refreshing?).to be_truthy
        end
      end

      context "updated in last #{DocumentSearch::REFRESH_INTERVAL} minutes" do
        specify do
          travel_to(@recent_time) do
            @c.update!(elib_legacy_id: 1)
          end

          expect(@c.reload.updated_at).to be > @refresh_threshold
          expect(@d.reload.updated_at).to be > @refresh_threshold
          expect(DocumentSearch.citations_need_refreshing?).to be_truthy
        end
      end

      context "destroyed in last #{DocumentSearch::REFRESH_INTERVAL} minutes" do
        specify do
          travel_to(@recent_time) do
            @c.destroy
          end

          expect(@d.reload.updated_at).to be > @refresh_threshold
          expect(DocumentSearch.citations_need_refreshing?).to be_truthy
        end
      end
    end

    context 'when DocumentCitationTaxonConcept' do
      context "created in last #{DocumentSearch::REFRESH_INTERVAL} minutes" do
        specify do
          travel_to(@recent_time) do
            create(:document_citation_taxon_concept, document_citation: @c)
          end

          expect(@c.reload.updated_at).to be > @refresh_threshold
          expect(@d.reload.updated_at).to be > @refresh_threshold
          expect(DocumentSearch.citations_need_refreshing?).to be_truthy
        end
      end

      context "destroyed in last #{DocumentSearch::REFRESH_INTERVAL} minutes" do
        specify do
          travel_to(@recent_time) do
            @c_tc.destroy
          end

          expect(@c.reload.updated_at).to be > @refresh_threshold
          expect(@d.reload.updated_at).to be > @refresh_threshold
          expect(DocumentSearch.citations_need_refreshing?).to be_truthy
        end
      end

      context "updated in last #{DocumentSearch::REFRESH_INTERVAL} minutes" do
        specify do
          travel_to(@recent_time) do
            @c_tc.update!(taxon_concept_id: create_cites_eu_species.id)
          end

          expect(@c.reload.updated_at).to be > @refresh_threshold
          expect(@d.reload.updated_at).to be > @refresh_threshold
          expect(DocumentSearch.citations_need_refreshing?).to be_truthy
        end
      end
    end

    context 'when DocumentCitationGeoEntity' do
      context "created in last #{DocumentSearch::REFRESH_INTERVAL} minutes" do
        specify do
          travel_to(@recent_time) do
            create(:document_citation_taxon_concept, document_citation: @c)
          end

          expect(@c.reload.updated_at).to be > @refresh_threshold
          expect(@d.reload.updated_at).to be > @refresh_threshold
          expect(DocumentSearch.citations_need_refreshing?).to be_truthy
        end
      end

      context "destroyed in last #{DocumentSearch::REFRESH_INTERVAL} minutes" do
        specify do
          travel_to(@recent_time) do
            @c_ge.destroy
          end

          expect(@c.reload.updated_at).to be > @refresh_threshold
          expect(@d.reload.updated_at).to be > @refresh_threshold
          expect(DocumentSearch.citations_need_refreshing?).to be_truthy
        end
      end

      context "updated in last #{DocumentSearch::REFRESH_INTERVAL} minutes" do
        specify do
          travel_to(@recent_time) do
            @c_ge.update!(geo_entity_id: @ge2.id)
          end

          expect(@c.reload.updated_at).to be > @refresh_threshold
          expect(@d.reload.updated_at).to be > @refresh_threshold
          expect(DocumentSearch.citations_need_refreshing?).to be_truthy
        end
      end
    end
  end
end
