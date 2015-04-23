class Admin::<%= controller_class_name %>Controller < ApplicationController

  layout "l/admin"

  def index
    authorize! :manage, <%= class_name %>
    @<%= plural_table_name %> = <%= class_name %>
      .filter(params[:filter])

    @<%= plural_table_name %> = @<%= plural_table_name %>.order(sort_order) if sort_results?
    @<%= plural_table_name %> = @<%= plural_table_name %>.all.paginate page: params[:page]

    respond_to do |format|
      format.html
      format.js
    end
  end

  def new
    @<%= singular_table_name %> = <%= orm_class.build(class_name) %>
    authorize! :create, @<%= singular_table_name %>

    respond_to do |format|
      format.html
      format.js
    end
  end

  def edit
    @<%= singular_table_name %> = <%= orm_class.find(class_name, "params[:id]") %>
    authorize! :update, @<%= singular_table_name %>

    respond_to do |format|
      format.html
      format.js
    end
  end

  def edit_draft
    @<%= singular_table_name %> = <%= orm_class.find(class_name, "params[:id]") %>.draft
    authorize! :update, @<%= singular_table_name %>
    
    respond_to do |format|
      format.html
      format.js
    end
  end


  def create
    @<%= singular_table_name %> = <%= orm_class.build(class_name, "params[:#{singular_table_name}]") %>
    authorize! :create, @<%= singular_table_name %>

    respond_to do |format|
      if @<%= orm_instance.save %>
        @<%= singular_table_name %>.create_activity :create, owner: current_user
        flash.notice =  info(:success)
        format.html { redirect_to(admin_<%= plural_table_name %>_path ) }

      else
        format.html { render action: "new" }
      end
      format.js
    end
  end

  def update
    @<%= singular_table_name %> = <%= orm_class.find(class_name, "params[:id]") %>
    authorize! :update, @<%= singular_table_name %>

    respond_to do |format|
      if params.has_key?(:commit)
          if @<%= orm_instance.update_attributes("params[:#{singular_table_name}]") %>
            @<%= singular_table_name %>.create_activity :update, owner: current_user
            flash.notice =  info(:success)
            format.html { redirect_to(admin_<%= plural_table_name %>_path ) }
          else
            format.html { render action: "edit" }
          end
          format.js
        elsif params.has_key?(:create_draft)
          if @<%= singular_table_name %>.instantiate_draft!
            flash.notice = info(:success_draft)
            format.html { render action: "edit" }
            format.js
          else
            format.html { render action: "edit" }
            format.js
          end
        end
    end
  end

  def update_draft
      @<%= singular_table_name %> = <%= class_name %>::Draft.find(params[:id])
      
      respond_to do |format|
      if params.has_key?(:save_draft)
        if @<%= singular_table_name %>.update_attributes(params[:<%= singular_table_name %>_draft])
          flash.notice = info(:success)
          format.html 
          format.js
        else
          format.html { render action: "edit_draft" }
          format.js
         end
      elsif params.has_key?(:delete_draft)
            @<%= singular_table_name %> = @<%= singular_table_name %>.<%= singular_table_name %>
            @<%= singular_table_name %>.destroy_draft! 
            format.html {redirect_to edit_admin_<%= singular_table_name %>_path(@<%= singular_table_name %>), notice: info(:success) }
            
      elsif params.has_key?(:publish_draft)
          @<%= singular_table_name %> = @<%= singular_table_name %>.<%= singular_table_name %>
          
          if @<%= singular_table_name %>.replace_with_draft!
            @<%= singular_table_name %>.destroy_draft!
            format.html {redirect_to edit_admin_<%= singular_table_name %>_path(@<%= singular_table_name %>), notice: info(:success) }
          else
              format.html { render action: "edit_draft" }
              format.js
          end
      end
      end 
          
    end

  def destroy
    @<%= singular_table_name %> = <%= orm_class.find(class_name, "params[:id]") %>
    authorize! :destroy, @<%= singular_table_name %>
    @<%= orm_instance.destroy %>
    @<%= singular_table_name %>.create_activity :destroy, owner: current_user

    respond_to do |format|
      format.html { redirect_to :back, notice: info(:success) }
      format.any  { head :ok }
    end
  end

  def selection
    authorize! :manage, <%= class_name %>
    selection = {
      action: params[:bulk_action],
      ids: params[:ids]
    }
    selection = <%= class_name %>.selection_object(selection)

    respond_to do |format|
      if selection.perform!
        selection.each do |obj|
          obj.create_activity selection.action, owner: current_user
        end
        format.html { redirect_to :back, notice: info(selection.action, :success) }
      else
        format.html { redirect_to :back, alert: info(selection.action, :failure) }
      end
    end
  end

end
