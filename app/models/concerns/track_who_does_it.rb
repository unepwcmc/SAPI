module TrackWhoDoesIt
  extend ActiveSupport::Concern

  included do
    before_create :track_who_does_it_create_callback
    before_update :track_who_does_it_update_callback
    belongs_to :creator, class_name: 'User', foreign_key: 'created_by_id', optional: true
    belongs_to :updater, class_name: 'User', foreign_key: 'updated_by_id', optional: true
  end

private

  def track_who_does_it_create_callback
    current_user = RequestStore.store[:track_who_does_it_current_user]
    self.creator = current_user if respond_to?(:creator) && current_user
    self.updater = current_user if respond_to?(:updater) && current_user
  end

  def track_who_does_it_update_callback
    current_user = RequestStore.store[:track_who_does_it_current_user]
    self.updater = current_user if respond_to?(:updater) && current_user
  end
end
