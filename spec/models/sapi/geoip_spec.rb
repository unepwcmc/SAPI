require 'spec_helper'

describe SapiModule::GeoIP do
  describe :resolve do
    subject { SapiModule::GeoIP.instance }
    before(:each) do
      bogota_latin1 = 'Bogotá'.encode('ISO-8859-1', 'UTF-8')
      allow(subject).to receive(:country_and_city).and_return(
        {
          country: 'Colombia',
          city: bogota_latin1
        }
      )
    end
    specify { expect(subject.resolve('1.1.1.1')[:city]).to eq('Bogotá') }
  end
end
