# == Schema Information
#
# Table name: bulk_downloads
#
#  id              :bigint           not null, primary key
#  completed_at    :datetime
#  download_type   :string           not null
#  error_message   :jsonb
#  expires_at      :datetime
#  filters         :jsonb            not null
#  format          :string           not null
#  is_public       :boolean          default(FALSE), not null
#  started_at      :datetime
#  success_message :jsonb
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  requestor_id    :bigint
#
# Indexes
#
#  index_bulk_downloads_on_requestor_id         (requestor_id)
#  index_bulk_downloads_on_requestor_id_and_id  (requestor_id,id)
#
# Foreign Keys
#
#  fk_rails_...  (requestor_id => users.id)
#
class BulkDownload < ApplicationRecord
  belongs_to :user,
    foreign_key: :requestor_id,
    optional: true,
    inverse_of: :bulk_downloads

  has_one_attached :download
end
