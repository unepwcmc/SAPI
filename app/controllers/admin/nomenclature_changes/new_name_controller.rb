class Admin::NomenclatureChanges::NewNameController < Admin::NomenclatureChanges::BuildController

  steps *NomenclatureChange::NewName::STEPS

  def show
    builder = NomenclatureChange::NewName::Constructor.new(@nomenclature_change)
    case step
    when :name_status
      builder.build_output
    when :parent
      #for synonyms not setting the parent will lead to a failure of the new_full_name method for output
      set_new_name_taxonomy
      #skip_or_previous_step if @nomenclature_change.output.new_name_status != 'A'
      skip_or_previous_step unless ['A','N'].include?(@nomenclature_change.output.new_name_status)
    when :accepted_names
      set_new_name_taxonomy
      skip_or_previous_step if ['A','H','N'].include?(@nomenclature_change.output.new_name_status)
    when :hybrid_parents
      set_new_name_taxonomy
      hybrid_skip_or_previous_step if @nomenclature_change.output.new_name_status != 'H'
    when :summary
      processor = NomenclatureChange::NewName::Processor.new(@nomenclature_change)
      @summary = processor.summary
    end
    render_wizard
  end

  def update
    @nomenclature_change.assign_attributes(
      (params[:nomenclature_change_new_name] || {}).merge({
        :status => (step == steps.last ? NomenclatureChange::SUBMITTED : step.to_s)        
      })
    )

    case step
    when :parent
      set_new_name_taxonomy
    end
    
    success = @nomenclature_change.valid?

    render_wizard @nomenclature_change
  end

  private
  def klass
    NomenclatureChange::NewName
  end

  def init_new_name nomenclature_change
    #output = nomenclature_change.build_output
    #tc = @nomenclature_change.output.build_new_taxon_concept
    nomenclature_change.assign_attributes({"output_attributes" =>
      { 
        "taxon_concept_id"=>"", 
        "new_parent_id"=>"2036", 
        "new_scientific_name"=>"lumpus#{@nomenclature_change.id}", 
        "new_author_year"=>"Ferdinando, 2014",
        "new_rank_id"=>8,
        "new_name_status"=>"A"
      }
    })
  end

  def output_attributes
    {"output_attributes" =>
      { 
        "taxon_concept_id"=>"", 
        "new_parent_id"=>"2036", 
        "new_scientific_name"=>"lumpus#{@nomenclature_change.id}", 
        "new_author_year"=>"Ferdinando, 2014",
        "new_rank_id"=>8,
        "new_name_status"=>"A"
      }.merge(params[:nomenclature_change_new_name][:output_attributes])
    }
  end

  def set_new_name_taxonomy
    @taxonomy = Taxonomy.find(@nomenclature_change.output.taxonomy_id)
  end

  def hybrid_skip_or_previous_step
    if params[:back]
      if @nomenclature_change.output.new_name_status != 'A'
        jump_to(:rank)
      else
        jump_to(previous_step)
      end
    else
      skip_step
    end
  end

end
