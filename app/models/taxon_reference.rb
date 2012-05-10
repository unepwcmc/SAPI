# == Schema Information
#
# Table name: taxon_references
#
#  id                 :integer         not null, primary key
#  referenceable_id   :integer
#  referenceable_type :string(255)     default("Taxon"), not null
#  reference_id       :integer         not null
#  created_at         :datetime        not null
#  updated_at         :datetime        not null
#

class TaxonReference < ActiveRecord::Base
  # attr_accessible :title, :body
end
