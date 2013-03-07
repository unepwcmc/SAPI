shared_context :designations do
  #those referenced in factories need to go into the before(:all) block
  before(:all) do
    @cites_eu = create(:taxonomy, :name => Taxonomy::CITES_EU)
    @cites = create(:designation, :name => 'CITES', :taxonomy => @cites_eu)
    @eu = create(:designation, :name => 'EU', :taxonomy => @cites_eu)
    %w(ADDITION DELETION RESERVATION RESERVATION_WITHDRAWAL).each do |ch|
      instance_variable_set(
        :"@cites_#{ch.downcase}",
        create(:change_type, :name => ch, :designation => cites)
      )
      instance_variable_set(
        :"@eu_#{ch.downcase}",
        create(:change_type, :name => ch, :designation => eu)
      )
    end
  end
  #those referenced in specs can be lazily evaluated
  let(:cites_eu){ @cites_eu }
  let(:cms){ create(:taxonomy, :name => Taxonomy::CMS) }
  let(:cites){ @cites }
  let(:eu){ @eu }
end