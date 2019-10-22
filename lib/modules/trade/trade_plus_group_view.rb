class Trade::TradePlusGroupView

  VIEW_DIR = 'db/views/trade_plus_group_view'.freeze

  def initialize
    @mapping = YAML.load_file("#{Rails.root}/lib/data/trade_mapping.yml")
    @query = formatted_query
  end

  def generate_view(timestamp)
    Dir.mkdir(VIEW_DIR) unless Dir.exists?(VIEW_DIR)
    File.open("#{VIEW_DIR}/#{timestamp}.sql", 'w') { |f| f.write(@query) }
  end

  private

  def formatted_query
    <<-SQL
    SELECT
      ts.*,
      CASE #{add_group_mapping}
    FROM trade_shipments_with_taxa_view ts
    SQL
  end

  GROUP_MAPPING = {
    'class'=> 'taxon_concept_class_name',
    'genus'=> 'taxon_concept_genus_name',
    'taxon'=> 'taxon_concept_full_name'
  }.freeze

  def add_group_mapping
    query = ''
    map = @mapping['rules']['add_group']
    map.each do |rule|
      input = rule['input'].first
      rank = GROUP_MAPPING[input.first]
      values  = input.second.map { |a| "'#{a}'" }.join(',')
      next if values.blank?
      group = rule['output']['group']
      byebug
      query += "\t\t\tWHEN #{rank} IN (#{values}) THEN #{group}\n"
    end
    query += "\t\t\tWHEN ts.taxon_concept_class_name IS NULL AND (ts.taxon_concept_genus_name NOT IN ('Aquilaria','Pericopsis','Cedrela','Guaiacum','Swietenia','Dalbergia','Prunus','Gonystylus','Diospyros','Abies','Guarea','Guibourtia','Gyrinops','Platymiscium','Pterocarpus','Taxus')
      OR ts.taxon_concept_full_name NOT IN ('Araucaria araucana','Fitzroya cupressoides','Abies guatemalensis','Pterocarpus santalinus','Pilgerodendron uviferum','Aniba rosaeodora','Caesalpinia echinata','Bulnesia sarmientoi','Dipteryx panamensis','Pinus koraiensis','Caryocar costaricense','Celtis aetnensis','Cynometra hemitomophylla','Magnolia liliifera','Oreomunnea pterocarpa','Osyris lanceolata','Pterygota excelsa','Tachigali versicolor'))
      THEN 'Plants'\n"
    query += "\t\t\tEND AS group"
  end
end
