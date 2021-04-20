# REQUIRES SIEGE TO BE INSTALLED
# Brew is an option for installing siege.

# PARAMS
PARAMS = {
  start_year: {
    values: [2011, 2012, 2013, 2014, 2015, 2016, 2017, 2018],
    multiple: false
  },
  term_ids: {
    # Live, Stems, Skins, Medicine, Eggs (Live)
    values: [57, 89, 84, 60, 23],
    multiple: true
  },
  taxonomic_groups: {
    values: ['Plants', 'Mammals'],
    multiple: true
  },
  taxon_ids: {
    # Orchidaceae, Aves, Plantae, Phalaenopsis, Galanthus, Macaca fascicularis, Scleractinia, Alligator mississippiensis, Acipenser, Acipenser baerii
    values: [12509, 333, 45, 12827, 13395, 3920, 78, 6810, 1528, 9647],
    multiple: true
  },
  country_ids: {
    # USA, China, Thailand, Turkey, Germany, Netherlands
    values: [80, 160, 230, 112, 23, 165],
    multiple: true
  },
  reported_by: {
    values: ['exporter', 'importer'],
    multiple: false
  },
  reported_by_party: {
    values: [true, false],
    multiple: false
  },
  unit: {
    # no. items, kg, m^3
    values: ['items', '143', '136'],
    multiple: false
  },
}.freeze

PARAM_PERMUTATIONS = 10 # To avoid hitting too much caching
CONCURRENT = 80 # (country page = 8 requests) * 10 users
TIME = '10M'
URL_TEMPLATE_FILENAME = './staging-urls-template.txt'
TMP_FILENAME = "#{File.expand_path(File.dirname(__FILE__))}/staging-urls.txt"

def get_random_values(param)
  values = param[:values]

  if param[:multiple]
    values.sample(1 + rand(values.count)).join(',')
  else
    values.sample
  end
end

def get_value(params, key)
  if params.nil? 
    raise "The placeholder '${#{key}}' can not be replaced as no params hash is provided."
  end
  
  param = params[key.to_sym]

  if param.nil?
    raise "The key '#{key}' does not exist in the given params hash."
  else
    get_random_values(param)
  end
end

def str_replace(str, values)
  str.gsub(/\${([^}]*)}/) do
    begin
      value = get_value(values, $1)
    rescue => e
      puts e
    end

    value ? value : $1 
  end
end

def create_staging_urls_file()
  text = File.read(URL_TEMPLATE_FILENAME)
  new_text = str_replace(text, PARAMS)
  
  File.open(TMP_FILENAME, 'w') { |file| 
    PARAM_PERMUTATIONS.times do
      file.write(new_text) 
    end
  }
end

def run_test ()
  create_staging_urls_file()

  puts `siege --delay=0.5 --file=staging-urls.txt --internet --verbose --time=#{TIME} --concurrent=#{CONCURRENT}`

  File.delete(TMP_FILENAME)
end

run_test()