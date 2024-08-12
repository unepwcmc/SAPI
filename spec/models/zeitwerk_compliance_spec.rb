require 'spec_helper'

# https://guides.rubyonrails.org/classic_to_zeitwerk_howto.html#rspec
RSpec.describe 'Zeitwerk compliance' do
  it 'eager loads all files without errors' do
    expect { Rails.application.eager_load! }.not_to raise_error
  end
end
