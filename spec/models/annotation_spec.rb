require 'spec_helper'

describe Annotation do
  describe :full_name do
    let(:annotation){
      create(:annotation, :parent_symbol => 'CoP1', :symbol => '#1')
    }
    specify{ annotation.full_symbol == 'CoP1#1' }
  end
end