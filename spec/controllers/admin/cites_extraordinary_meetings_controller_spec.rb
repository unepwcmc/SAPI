require 'spec_helper'

describe Admin::CitesExtraordinaryMeetingsController do
  login_admin

  describe "index" do
    before(:each) do
      @cites_ex1 = create_cites_extraordinary_meeting(name: 'Ex1')
      @cites_ex2 = create_cites_extraordinary_meeting(name: 'Ex2')
    end

    describe "GET index" do
      it "assigns @cites_extraordinary_meetings sorted by name" do
        get :index
        expect(assigns(:cites_extraordinary_meetings)).to eq([@cites_ex1, @cites_ex2])
      end
      it "renders the index template" do
        get :index
        expect(response).to render_template("index")
      end
    end
  end

end
