require 'spec_helper'

describe Trade::TaxonConceptAppendixYearValidationRule, :drops_tables do
  describe :validation_errors_for_aru do
    before do
      @aru = build(:annual_report_upload)
      @aru.save(validate: false)
      @sandbox_klass = Trade::SandboxTemplate.ar_klass(@aru.sandbox.table_name)
    end

    context 'when CITES listed' do
      before do
        genus = create_cites_eu_genus(
          taxon_name: create(:taxon_name, scientific_name: 'Loxodonta')
        )
        @species = create_cites_eu_species(
          taxon_name: create(:taxon_name, scientific_name: 'africana'),
          parent_id: genus.id
        )
        create_cites_I_addition(
          taxon_concept: @species,
          effective_at: '1990-01-18'
        )
        create_cites_I_addition(
          taxon_concept: @species,
          effective_at: '1997-09-18',
          is_current: true
        )
        cites_lc2 = create_cites_II_addition(
          taxon_concept: @species,
          effective_at: '1997-09-18',
          is_current: true
        )
        synonym = create_cites_eu_species(
          taxon_name: create(:taxon_name, scientific_name: 'Loxodonta cyclotis'),
          name_status: 'S'
        )
        create(
          :taxon_relationship,
          taxon_relationship_type: synonym_relationship_type,
          taxon_concept: @species,
          other_taxon_concept: synonym
        )
        SapiModule::StoredProcedures.rebuild_cites_taxonomy_and_listings
      end

      context 'when split listing' do
        subject do
          create_taxon_concept_appendix_year_validation
        end

        before do
          @sandbox_klass.create(
            taxon_name: 'Loxodonta africana', appendix: 'I', year: '1997'
          )
          @sandbox_klass.create(
            taxon_name: 'Loxodonta africana', appendix: 'II', year: '1997'
          )
        end


        specify do
          subject.refresh_errors_if_needed(@aru)
          expect(subject.validation_errors_for_aru(@aru).size).to eq(0)
        end
      end

      context 'when old listing' do
        subject do
          create_taxon_concept_appendix_year_validation
        end

        before do
          @sandbox_klass.create(
            taxon_name: 'Loxodonta africana', appendix: 'II', year: '1996'
          )
          @sandbox_klass.create(
            taxon_name: 'Loxodonta africana', appendix: 'I', year: '1996'
          )
        end


        specify do
          subject.refresh_errors_if_needed(@aru)
          expect(subject.validation_errors_for_aru(@aru).size).to eq(1)
        end

        specify do
          subject.refresh_errors_if_needed(@aru)
          ve = subject.validation_errors_for_aru(@aru).first
          expect(ve.error_message).to eq('taxon_name Loxodonta africana with appendix II with year 1996 is invalid')
        end
      end

      context 'when appendix N and CITES listed' do
        subject do
          create_taxon_concept_appendix_year_validation
        end

        before do
          @sandbox_klass.create(
            taxon_name: 'Loxodonta africana', appendix: 'N', year: '1996'
          )
        end


        specify do
          subject.refresh_errors_if_needed(@aru)
          expect(subject.validation_errors_for_aru(@aru).size).to eq(1)
        end

        specify do
          subject.refresh_errors_if_needed(@aru)
          ve = subject.validation_errors_for_aru(@aru).first
          expect(ve.error_message).to eq('taxon_name Loxodonta africana with appendix N with year 1996 is invalid')
        end
      end

      context 'when reported under a synonym, but otherwise fine' do
        subject do
          create_taxon_concept_appendix_year_validation
        end

        before do
          @sandbox_klass.create(
            taxon_name: 'Loxodonta cyclotis', appendix: 'I', year: '2013'
          )
        end


        specify do
          subject.refresh_errors_if_needed(@aru)
          expect(subject.validation_errors_for_aru(@aru).size).to eq(0)
        end
      end

      context 'when hybrid' do
        subject do
          create_taxon_concept_appendix_year_validation
        end

        before do
          falconidae = create_cites_eu_family(
            taxon_name: create(:taxon_name, scientific_name: 'Falconidae')
          )
          falco = create_cites_eu_genus(
            taxon_name: create(:taxon_name, scientific_name: 'Falco'),
            parent: falconidae
          )
          falco_hybrid = create_cites_eu_species(
            taxon_name: create(:taxon_name, scientific_name: 'Falco hybrid'),
            name_status: 'H'
          )
          create(
            :taxon_relationship,
            taxon_relationship_type: create(:taxon_relationship_type, name: 'HAS_HYBRID'),
            taxon_concept: falco,
            other_taxon_concept: falco_hybrid
          )
          create_cites_II_addition(
            taxon_concept: falconidae,
            effective_at: '1979-06-28',
            is_current: true
          )
          SapiModule::StoredProcedures.rebuild_cites_taxonomy_and_listings
          @sandbox_klass.create(
            taxon_name: 'Falco hybrid', appendix: 'II', year: '2012'
          )
        end


        specify do
          subject.refresh_errors_if_needed(@aru)
          expect(subject.validation_errors_for_aru(@aru).size).to eq(0)
        end
      end
    end

    context 'when not CITES listed but EU listed' do
      subject do
        create_taxon_concept_appendix_year_validation
      end

      include_context 'Cedrela montana'
      before do
        @sandbox_klass.create(
          taxon_name: 'Cedrela montana', appendix: 'N', year: '2013'
        )
      end


      specify do
        subject.refresh_errors_if_needed(@aru)
        expect(subject.validation_errors_for_aru(@aru).size).to eq(0)
      end
    end

    context 'when not CITES listed and not EU listed' do
      subject do
        create_taxon_concept_appendix_year_validation
      end

      include_context 'Agave'
      before do
        @sandbox_klass.create(
          taxon_name: 'Agave arizonica', appendix: 'N', year: '2013'
        )
      end


      specify do
        subject.refresh_errors_if_needed(@aru)
        expect(subject.validation_errors_for_aru(@aru).size).to eq(1)
      end
    end
  end
end
