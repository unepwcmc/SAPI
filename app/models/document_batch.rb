class DocumentBatch
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
  attr_reader :event_id, :language_id, :date, :is_public, :documents
  validates :date, presence: true
  validates :documents, presence: true, allow_blank: false

  def initialize(attributes = {})
    @event_id = attributes[:event_id]
    @language_id = attributes[:language_id]
    @date = attributes[:date]
    @is_public = attributes[:is_public]
    initialize_documents(attributes[:documents_attributes], attributes[:files])
  end

  def save
    return false unless valid?
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

  def persisted?
    false
  end

  private

  def initialize_documents(documents_attributes, files)
    @documents = []
    if documents_attributes && files
      for idx in 0..(files.length - 1) do
        document_params = {
          type: documents_attributes[idx.to_s][:type],
          filename: files[idx]
        }
        @documents.push(Document.new(common_attributes.merge(document_params)))
      end
    end
  end

  def common_attributes
    {
      'event_id' => @event_id,
      'date' => @date,
      'language_id' => @language_id,
      'is_public' => ActiveRecord::ConnectionAdapters::Column.value_to_boolean(@is_public)
    }
  end

end
