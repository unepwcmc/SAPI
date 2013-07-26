# == Schema Information
#
# Table name: annotations
#
#  id                  :integer          not null, primary key
#  symbol              :string(255)
#  parent_symbol       :string(255)
#  display_in_index    :boolean          default(FALSE), not null
#  display_in_footnote :boolean          default(FALSE), not null
#  short_note_en       :text
#  full_note_en        :text
#  short_note_fr       :text
#  full_note_fr        :text
#  short_note_es       :text
#  full_note_es        :text
#  source_id           :integer
#  event_id            :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  import_row_id       :integer
#

require 'spec_helper'

describe Annotation do
  describe :full_name do
    context "when parent_symbol given" do
      let(:annotation){
        create(:annotation, :parent_symbol => 'CoP1', :symbol => '#1')
      }
      specify{ annotation.full_symbol == 'CoP1#1' }
    end
    context "when event given" do
      let(:event){ create_cites_cop(:name => 'CoP1') }
      let(:annotation){
        create(:annotation, :event_id => event.id, :symbol => '#1')
      }
      specify{ annotation.full_symbol == 'CoP1#1' }
    end
  end
end
