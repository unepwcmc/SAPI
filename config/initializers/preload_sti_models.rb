# https://guides.rubyonrails.org/autoloading_and_reloading_constants.html#single-table-inheritance

# https://guides.rubyonrails.org/autoloading_and_reloading_constants.html#option-2-preload-a-collapsed-directory
events = "#{Rails.root}/app/models/events"
Rails.autoloaders.main.collapse(events)
trade_codes = "#{Rails.root}/app/models/trade_codes"
Rails.autoloaders.main.collapse(trade_codes)
trade_restrictions = "#{Rails.root}/app/models/trade_restrictions"
Rails.autoloaders.main.collapse(trade_restrictions)
eu_decisions = "#{Rails.root}/app/models/eu_decisions"
Rails.autoloaders.main.collapse(eu_decisions)
cites_processes = "#{Rails.root}/app/models/cites_processes"
Rails.autoloaders.main.collapse(cites_processes)

unless Rails.application.config.eager_load
  Rails.application.config.to_prepare do
    # https://guides.rubyonrails.org/autoloading_and_reloading_constants.html#option-2-preload-a-collapsed-directory
    Rails.autoloaders.main.eager_load_dir(events)
    Rails.autoloaders.main.eager_load_dir(trade_codes)
    Rails.autoloaders.main.eager_load_dir(trade_restrictions)
    Rails.autoloaders.main.eager_load_dir(eu_decisions)
    Rails.autoloaders.main.eager_load_dir(cites_processes)
    # https://guides.rubyonrails.org/autoloading_and_reloading_constants.html#option-3-preload-a-regular-directory
    Rails.autoloaders.main.eager_load_dir("#{Rails.root}/app/models/document")
    Rails.autoloaders.main.eager_load_dir("#{Rails.root}/app/models/document_tag")
    Rails.autoloaders.main.eager_load_dir("#{Rails.root}/app/models/nomenclature_change")
  end
end
