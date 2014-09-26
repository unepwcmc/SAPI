# == Schema Information
#
# Table name: documents
#
#  id            :integer          not null, primary key
#  title         :text             not null
#  filename      :text             not null
#  date          :date             not null
#  type          :string(255)      not null
#  is_public     :boolean          default(FALSE), not null
#  event_id      :integer
#  language_id   :integer
#  legacy_id     :integer
#  created_by_id :integer
#  updated_by_id :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  number        :string(255)
#

class Document::CommissionNotes < Document
  def self.display_name; 'Commission Notes'; end
end
