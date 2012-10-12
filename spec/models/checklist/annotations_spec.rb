#Encoding: UTF-8
require 'spec_helper'

describe Checklist do
  include_context "Caiman latirostris"

  describe "specific annotation" do
    before(:all) do
      @checklist = Checklist.new({
        :scientific_name => 'Crocodylia',
        :locale => 'en'
      })
      @taxon_concepts = @checklist.taxon_concepts_rel
    end
  end
end