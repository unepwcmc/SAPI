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
      let(:event){ create(:cites_cop, :name => 'CoP1') }
      let(:annotation){
        create(:annotation, :event_id => event.id, :symbol => '#1')
      }
      specify{ annotation.full_symbol == 'CoP1#1' }
    end
  end
end