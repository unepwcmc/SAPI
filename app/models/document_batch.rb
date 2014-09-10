class DocumentBatch
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
  attr_accessor :event_id, :language_id, :date, :is_public, :documents

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def save
    success = true
    Document.transaction do
      @documents.each do |d|
        unless d.save
          success = false
        end
      end
      raise ActiveRecord::Rollback unless success
    end
    success
  end

  def self.association association, klass
    @@attributes ||= {}
    @@attributes[association] = klass
  end

  association :documents, Document

  def self.reflect_on_association(association)
    data = { klass: @@attributes[association] }
    OpenStruct.new data
  end

  def common_attributes
    {
      'event_id' => event_id,
      'date' => date,
      'language_id' => language_id,
      'is_public' => ActiveRecord::ConnectionAdapters::Column.value_to_boolean(is_public)
    }
  end

  def documents_attributes=(attributes)
    @documents ||= []
    attributes.each do |_, document_params|
      destroy = ActiveRecord::ConnectionAdapters::Column.value_to_boolean(document_params.delete(:_destroy))
      @documents.push(Document.new(common_attributes.merge(document_params))) unless destroy
    end
  end

  def persisted?
    false
  end
end
