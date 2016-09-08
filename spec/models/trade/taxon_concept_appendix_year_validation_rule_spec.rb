# == Schema Information
#
# Table name: trade_validation_rules
#
#  id                :integer          not null, primary key
#  valid_values_view :string(255)
#  type              :string(255)      not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  format_re         :string(255)
#  run_order         :integer          not null
#  column_names      :string(255)
#  is_primary        :boolean          default(TRUE), not null
#  scope             :hstore
#  is_strict         :boolean          default(FALSE), not null
#

require 'spec_helper'

describe Trade::TaxonConceptAppendixYearValidationRule, :drops_tables => true do
  describe :validation_errors_for_aru do

    before(:each) do
      @aru = build(:annual_report_upload)
      @aru.save(:validate => false)
      @sandbox_klass = Trade::SandboxTemplate.ar_klass(@aru.sandbox.table_name)
    end

    context "when CITES listed" do
      before(:each) do
        genus = create_cites_eu_genus(
          :taxon_name => create(:taxon_name, :scientific_name => 'Loxodonta')
        )
        @species = create_cites_eu_species(
          :taxon_name => create(:taxon_name, :scientific_name => 'africana'),
          :parent_id => genus.id
        )
        create_cites_I_addition(
          :taxon_concept => @species,
          :effective_at => '1990-01-18'
        )
        create_cites_I_addition(
          :taxon_concept => @species,
          :effective_at => '1997-09-18',
          :is_current => true
        )
        cites_lc2 = create_cites_II_addition(
          :taxon_concept => @species,
          :effective_at => '1997-09-18',
          :is_current => true
        )
        synonym = create_cites_eu_species(
          :taxon_name => create(:taxon_name, :scientific_name => 'Loxodonta cyclotis'),
          :name_status => 'S'
        )
        create(
          :taxon_relationship,
          :taxon_relationship_type => synonym_relationship_type,
          :taxon_concept => @species,
          :other_taxon_concept => synonym
        )
        Sapi::StoredProcedures.rebuild_cites_taxonomy_and_listings
      end

      context "when split listing" do
        before(:each) do
          @sandbox_klass.create(
            :taxon_name => 'Loxodonta africana', :appendix => 'I', :year => '1997'
          )
          @sandbox_klass.create(
            :taxon_name => 'Loxodonta africana', :appendix => 'II', :year => '1997'
          )
        end
        subject {
          create_taxon_concept_appendix_year_validation
        }
        specify {
          subject.refresh_errors_if_needed(@aru)
          subject.validation_errors_for_aru(@aru).size.should == 0
        }
      end
      context "when old listing" do
        before(:each) do
          @sandbox_klass.create(
            :taxon_name => 'Loxodonta africana', :appendix => 'II', :year => '1996'
          )
          @sandbox_klass.create(
            :taxon_name => 'Loxodonta africana', :appendix => 'I', :year => '1996'
          )
        end
        subject {
          create_taxon_concept_appendix_year_validation
        }
        specify {
          subject.refresh_errors_if_needed(@aru)
          subject.validation_errors_for_aru(@aru).size.should == 1
        }
        specify {
          subject.refresh_errors_if_needed(@aru)
          ve = subject.validation_errors_for_aru(@aru).first
          ve.error_message.should == 'taxon_name Loxodonta africana with appendix II with year 1996 is invalid'
        }
      end
      context "when appendix N and CITES listed" do
        before(:each) do
          @sandbox_klass.create(
            :taxon_name => 'Loxodonta africana', :appendix => 'N', :year => '1996'
          )
        end
        subject {
          create_taxon_concept_appendix_year_validation
        }
        specify {
          subject.refresh_errors_if_needed(@aru)
          subject.validation_errors_for_aru(@aru).size.should == 1
        }
        specify {
          subject.refresh_errors_if_needed(@aru)
          ve = subject.validation_errors_for_aru(@aru).first
          ve.error_message.should == 'taxon_name Loxodonta africana with appendix N with year 1996 is invalid'
        }
      end
      context "when reported under a synonym, but otherwise fine" do
        before(:each) do
          @sandbox_klass.create(
            :taxon_name => 'Loxodonta cyclotis', :appendix => 'I', :year => '2013'
          )
        end
        subject {
          create_taxon_concept_appendix_year_validation
        }
        specify {
          subject.refresh_errors_if_needed(@aru)
          subject.validation_errors_for_aru(@aru).size.should == 0
        }
      end
      context "when hybrid" do
        before(:each) do
          falconidae = create_cites_eu_family(
            :taxon_name => create(:taxon_name, :scientific_name => 'Falconidae')
          )
          falco = create_cites_eu_genus(
            :taxon_name => create(:taxon_name, :scientific_name => 'Falco'),
            :parent => falconidae
          )
          falco_hybrid = create_cites_eu_species(
            :taxon_name => create(:taxon_name, :scientific_name => 'Falco hybrid'),
            :name_status => 'H'
          )
          create(
            :taxon_relationship,
            :taxon_relationship_type => create(:taxon_relationship_type, :name => 'HAS_HYBRID'),
            :taxon_concept => falco,
            :other_taxon_concept => falco_hybrid
          )
          create_cites_II_addition(
            :taxon_concept => falconidae,
            :effective_at => '1979-06-28',
            :is_current => true
          )
          Sapi::StoredProcedures.rebuild_cites_taxonomy_and_listings
          @sandbox_klass.create(
            :taxon_name => 'Falco hybrid', :appendix => 'II', :year => '2012'
          )
        end
        subject {
          create_taxon_concept_appendix_year_validation
        }
        specify {
          subject.refresh_errors_if_needed(@aru)
          subject.validation_errors_for_aru(@aru).size.should == 0
        }
      end
    end
    context "when not CITES listed but EU listed" do
      include_context "Cedrela montana"
      before(:each) do
        @sandbox_klass.create(
          :taxon_name => 'Cedrela montana', :appendix => 'N', :year => '2013'
        )
      end
      subject {
        create_taxon_concept_appendix_year_validation
      }
      specify {
        subject.refresh_errors_if_needed(@aru)
        subject.validation_errors_for_aru(@aru).size.should == 0
      }
    end
    context "when not CITES listed and not EU listed" do
      include_context "Agave"
      before(:each) do
        @sandbox_klass.create(
          :taxon_name => 'Agave arizonica', :appendix => 'N', :year => '2013'
        )
      end
      subject {
        create_taxon_concept_appendix_year_validation
      }
      specify {
        subject.refresh_errors_if_needed(@aru)
        subject.validation_errors_for_aru(@aru).size.should == 1
      }
    end
  end
end
