# == Schema Information
#
# Table name: annotation_translations
#
#  id            :integer          not null, primary key
#  annotation_id :integer          not null
#  language_id   :integer          not null
#  short_note    :string(255)
#  full_note     :text             not null
#

class AnnotationTranslation < ActiveRecord::Base
  attr_accessible :annotation_id, :language_id, :short_note, :full_note
end
