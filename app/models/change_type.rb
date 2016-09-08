# == Schema Information
#
# Table name: change_types
#
#  id              :integer          not null, primary key
#  name            :string(255)      not null
#  designation_id  :integer          not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  display_name_en :text             not null
#  display_name_es :text
#  display_name_fr :text
#

class ChangeType < ActiveRecord::Base
  attr_accessible :name, :display_name_en, :display_name_es, :display_name_fr,
    :designation_id
  include Dictionary
  build_dictionary :addition, :deletion, :reservation, :reservation_withdrawal, :exception

  translates :display_name

  belongs_to :designation
  has_many :listing_changes

  validates :name, :presence => true, :uniqueness => { :scope => :designation_id }
  validates :display_name_en, :presence => true, :uniqueness => { :scope => :designation_id }

  def abbreviation
    self.name.split('_').
      map { |a| a[0..2] }.join('-')
  end

  def print_name
    self.name.titleize
  end

  private

  def dependent_objects_map
    {
      'listing changes' => listing_changes
    }
  end
end
