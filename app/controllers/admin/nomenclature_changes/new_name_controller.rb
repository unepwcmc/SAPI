class Admin::NomenclatureChanges::NewNameController < Admin::NomenclatureChanges::BuildController

  steps *NomenclatureChange::NewName::STEPS

  before_filter :set_name_status, only: [:show]

  def show
    builder = NomenclatureChange::NewName::Constructor.new(@nomenclature_change)
    case step
    when :name_status
      builder.build_output
    when :parent
      set_new_name_taxonomy
      skip_or_previous_step unless ['A','N'].include?(@name_status)
    when :accepted_names
      set_new_name_taxonomy
      skip_or_previous_step if ['A','H','N'].include?(@name_status)
    when :hybrid_parents
      set_new_name_taxonomy
      skip_or_previous_step if @name_status != 'H'
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
    when :rank
      case @nomenclature_change.output.new_name_status
      when 'S' then jump_to(:accepted_names)
      when 'H' then jump_to(:hybrid_parents)
      end
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

  def set_name_status
    @name_status = ''
    if @nomenclature_change.output and
      [:parent, :accepted_names, :hybrid_parents].include?(step)
      @name_status = @nomenclature_change.output.new_name_status
    end
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

  def skip_or_previous_step
    if params[:back]
      if step == :accepted_names || step == :parent
        jump_to(:rank)
      elsif step == :hybrid_parents
        case @nomenclature_change.output.new_name_status
        when 'A' then jump_to(:parent)
        when 'S' then jump_to(:accepted_names)
        end
      end
    else
      skip_step
    end
  end

end
