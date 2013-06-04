# Constructs a normalised list of parameters, with non-recognised params
# removed.
#
# Array parameters are sorted for caching purposes.
class Species::SearchParams < Hash
  def initialize(params)
    sanitized_params = {
      #possible taxonomies are cms and cites_eu
      :taxonomy =>
        params[:taxonomy] ? params[:taxonomy].to_sym : nil,
      #filtering options
      :scientific_name => params[:scientific_name] ? params[:scientific_name] : nil
    }
    unless [:cites_eu, :cms].include? sanitized_params[:taxonomy]
      sanitized_params[:taxonomyt] = :cites_eu
    end
    super(sanitized_params)
    self.merge!(sanitized_params)
  end

  def self.sanitize(params)
    new(params)
  end

end
