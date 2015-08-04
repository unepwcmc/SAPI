require Rails.root.join('lib/tasks/elibrary/importable.rb')

class Elibrary::CitationsNdfImporter < Elibrary::CitationsImporter

  def columns_with_type
    super() + [
      ['NDFSource', 'TEXT']
    ]
  end

end
