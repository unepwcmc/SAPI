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
          filename: files[idx],
          title:  document_title(files[idx])
        }
        @documents.push(Document.new(common_attributes.merge(document_params)))
      end
    end
  end

  def common_attributes
    is_public = ActiveRecord::Type::Boolean.new.type_cast_from_database(@is_public) # Rails 4
    # is_public = ActiveRecord::Type::Boolean.new.cast(@is_public) # TODO Rails 5

    {
      'event_id' => @event_id,
      'date' => @date,
      'language_id' => @language_id,
      'is_public' => is_public
    }
  end

  def document_title(file)
    original_filename = file.is_a?(Hash) ? file[:filename].original_filename :  file.original_filename
    original_filename.sub(/.\w+$/, '')
  end
end
