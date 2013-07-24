class Species::ExportsController < ApplicationController
  # GET exports/
  #
  def index
    @designations = Designation.order('name')
    @cites = @designations.find_by_name(Designation::CITES)
    @eu = @designations.find_by_name(Designation::EU)
    @species_listings = SpeciesListing.order('name')
    @geo_entities = GeoEntity.joins(:geo_entity_type).
      where(:geo_entity_types => {:name => GeoEntityType::COUNTRY},
            :geo_entities => { :is_current => true }).
      order(:name_en)
    @taxon_concepts = MTaxonConcept.
      select([:"taxon_concepts_mview.id", :full_name, :"designations.id AS designation_id"]).
      joins('JOIN designations ON designations.taxonomy_id = taxon_concepts_mview.taxonomy_id').
      where(:rank_name => [Rank::CLASS, Rank::ORDER, Rank::FAMILY]).
      order(:full_name)
  end

  def download
    case params[:data_type]
      when 'Quotas'
        result = Quota.export params[:filters]
      when 'CitesSuspensions'
        result = CitesSuspension.export params[:filters]
      when 'Listings'
        result = Species::ListingsExportFactory.new(params[:filters]).export
    end
    respond_to do |format|
      format.html {
        if result.is_a?(Array)
          send_file result[0], result[1]
        else 
          redirect_to species_exports_path, :notice => "There are no #{params[:data_type]} to download."
        end
      }
      format.json {
        render :json => {:total => result.is_a?(Array) ? result.count : 0}
      }
    end
  end
end
