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
#

require 'spec_helper'

describe Trade::SpeciesNameAppendixYearValidationRule, :drops_tables => true do
  describe :validation_errors do

    before(:each) do
      genus = create_cites_eu_genus(
        :taxon_name => create(:taxon_name, :scientific_name => 'Loxodonta')
      )
      species = create_cites_eu_species(
        :taxon_name => create(:taxon_name, :scientific_name => 'africana'),
        :parent_id => genus.id
      )
      create_cites_I_addition(
       :taxon_concept => species,
       :effective_at => '1990-01-18'
      )
      create_cites_I_addition(
       :taxon_concept => species,
       :effective_at => '1997-09-18',
       :is_current => true
      )
      cites_lc2 = create_cites_II_addition(
       :taxon_concept => species,
       :effective_at => '1997-09-18',
       :is_current => true
      )
      Sapi.rebuild
      @aru = build(:annual_report_upload)
      @aru.save(:validate => false)
      @sandbox_klass = Trade::SandboxTemplate.ar_klass(@aru.sandbox.table_name)
    end

    context "when split listing" do
      before(:each) do
        @sandbox_klass.create(
          :species_name => 'Loxodonta africana', :appendix => 'I', :year => '1997'
        )
        @sandbox_klass.create(
          :species_name => 'Loxodonta africana', :appendix => 'II', :year => '1997'
        )
      end
      subject{
        create(:species_name_appendix_year_validation_rule)
      }
      specify{
        subject.validation_errors(@aru).size.should == 0
      }
    end
    context "when old listing" do
      before(:each) do
        @sandbox_klass.create(
          :species_name => 'Loxodonta africana', :appendix => 'II', :year => '1996'
        )
        @sandbox_klass.create(
          :species_name => 'Loxodonta africana', :appendix => 'I', :year => '1996'
        )
      end
      subject{
        create(:species_name_appendix_year_validation_rule)
      }
      specify{
        subject.validation_errors(@aru).size.should == 1
      }
      specify{
        ve = subject.validation_errors(@aru).first
        ve.error_selector.should == {'species_name' => 'Loxodonta africana', 'appendix' => 'II', 'year' => '1996'}
      }
    end
  end
end
