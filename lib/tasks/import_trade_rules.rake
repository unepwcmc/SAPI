require Rails.root.join('lib/tasks/helpers_for_import.rb')

namespace :import do
  desc 'import trade plus conversion rules'
  task trade_rules: [ :environment ] do
    path_to_groups_file = "#{Rails.application.root}/lib/data/trade_taxon_groups.yml"
    abort("File doesn't exist.") unless File.exist?(path_to_groups_file)
    groups_definition = YAML.load_file(path_to_groups_file)

    path_to_rules_file = "#{Rails.application.root}/lib/data/trade_mapping.yml"
    abort("File doesn't exist.") unless File.exist?(path_to_rules_file)
    rules_definition = YAML.load_file(path_to_rules_file)

    ApplicationRecord.transaction do
      Trade::ConversionRule.delete_all
      Trade::TaxonGroup.delete_all # skips AR triggers

      groups_definition.each do |row|
        Trade::TaxonGroup.create!(row)
      end

      rules_definition['rules'].each do |rule_type, rules|
        rules.each.with_index(1) do |row_original, rule_priority|
          Trade::ConversionRule.create!(
            rule_type: rule_type,
            rule_name: row_original['rule_name'],
            rule_priority: rule_priority,
            rule_input: row_original['input'],
            rule_output: row_original['output'],
          )
        end
      end
    end
  end
end
