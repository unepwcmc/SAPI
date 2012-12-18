class Admin::TermsController < Admin::AdminController
  inherit_resources
  respond_to :js, :only => [:create]
  respond_to :json, :only => [:update]

  def index
    index! do |format|
      format.html { render :template => 'admin/trade_codes/index' }
    end
  end

    def create
        @term = Term.new(params[:term])

        respond_to do |format|
            if @term.save
                format.html { redirect_to @term, :notice => 'Term was successfully created.' }
                # Send back the new term, we'll render it on the client side
                format.json { render :json => @term, :status => :created, :location => @term }
            else
                format.html { render :action => "new" }
                # Send back the errors as JSON, we'll render them on the client side
                format.json { render :json => @term.errors, :status => :unprocessable_entity }
                # Renders update.js.erb which replaces the body of the form with a newly
                # rendered version that will include the form errors
                format.js { render :template => 'admin/trade_codes/create' }
            end
        end
    end

    def update
        @term = Term.find(params[:id])

        respond_to do |format|
            if @term.update_attributes(params[:term])
                # Redirect to the term template
                format.html { redirect_to @term, :notice => 'Term was successfully updated.' }
                format.js { render :js => "window.location.replace('#{term_path(@term)}');"}
            else
                format.html { render :action => "edit" }
                # Renders update.js.erb which replaces the body of the form with a newly
                # rendered version that will include the form errors
                format.js {}
            end
        end
    end

  def destroy
    destroy! do |success, failure|
      success.html { redirect_to collection_url, :notice => 'Operation succeeded' }
      failure.html { redirect_to collection_url, :alert => 'Operation failed' }
    end
  end

  protected

  def collection
    @terms ||= end_of_association_chain.order('code').page(params[:page])
  end
end