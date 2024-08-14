# Load config for maxMind

GEO_IP_CONFIG = YAML.load_file("#{Rails.root.join("config/max_mind.yml")}")
