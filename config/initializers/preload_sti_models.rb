if Rails.env.development?

  require_dependency File.join("app", "models", "document.rb")
  Dir.glob(Rails.root.join("app/models/document/*.rb")).each do |path|
    require_dependency path
  end
  %w[cites_cop cites_ac cites_pc cites_tc cites_extraordinary_meeting ec_srg].each do |c|
    require_dependency File.join("app", "models", "#{c}.rb")
  end
end
