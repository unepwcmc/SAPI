# Resolves file_path's own extension to its concrete parser class - the single source
# of truth Importer::Base consults both at config-validation time (to validate the
# right delimiter/encoding or header_row/data_start_row macros - both parser classes'
# config is validated unconditionally regardless of which one file_path actually
# selects, matching this format's pre-refactor behavior) and to actually build the
# parser for a run.
module Importer::Parsers
  def self.class_for(file_path)
    case File.extname(file_path).downcase
    when '.xlsx' then Importer::Parsers::ExcelX
    else Importer::Parsers::Csv
    end
  end
end
