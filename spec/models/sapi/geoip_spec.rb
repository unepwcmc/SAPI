require 'spec_helper'

describe Sapi::GeoIP do
  describe :resolve do
    subject { Sapi::GeoIP.instance }
    before(:each) do
      bogota_latin1 = "Bogotá".encode('ISO-8859-1', 'UTF-8')
      subject.stub(:country_and_city).and_return(
        {
          country: 'Colombia',
          city: bogota_latin1
        }
      )
    end
    specify { subject.resolve('1.1.1.1')[:city].should == 'Bogotá' }
  end
end
