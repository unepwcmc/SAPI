class Admin::RanksController < Admin::AdminController
  inherit_resources

  def index
    @ranks = Rank.all
    index!
  end
end
