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
    end
  end

  def edit
    @<%= singular_table_name %> = <%= orm_class.find(class_name, "params[:id]") %>
    authorize! :update, @<%= singular_table_name %>

    respond_to do |format|
      format.html
    end
  end

  def create
    @<%= singular_table_name %> = <%= orm_class.build(class_name, "params[:#{singular_table_name}]") %>
    authorize! :create, @<%= singular_table_name %>

    respond_to do |format|
      if @<%= orm_instance.save %>
        format.html { redirect_to(admin_<%= plural_table_name %>_path, notice: info(:success) ) }
      else
        format.html { render action: "new" }
      end
    end
  end

  def update
    @<%= singular_table_name %> = <%= orm_class.find(class_name, "params[:id]") %>
    authorize! :update, @<%= singular_table_name %>

    respond_to do |format|
      if @<%= orm_instance.update_attributes("params[:#{singular_table_name}]") %>
        format.html { redirect_to(admin_<%= plural_table_name %>_path, notice: info(:success) ) }
      else
        format.html { render action: "edit" }
      end
    end
  end

  def destroy
    @<%= singular_table_name %> = <%= orm_class.find(class_name, "params[:id]") %>
    authorize! :destroy, @<%= singular_table_name %>
    @<%= orm_instance.destroy %>

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
        format.html { redirect_to :back, notice: info(selection.action, :success) }
      else
        format.html { redirect_to :back, alert: info(selection.action, :success) }
      end
    end
  end

end
