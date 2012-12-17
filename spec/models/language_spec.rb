# == Schema Information
#
# Table name: languages
#
#  id         :integer          not null, primary key
#  name_en    :string(255)
#  iso_code1  :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  name_fr    :string(255)
#  name_es    :string(255)
#

require 'spec_helper'

describe Language do
  pending "add some examples to (or delete) #{__FILE__}"
end
