class <%= controller_class_name %>Controller < ApplicationController

<% if used_tiny_mce_classes.size > 0 -%>
  uses_tinymce <%= used_tiny_mce_classes.to_s -%>, only: [:new, :edit, :create, :update]
<% end -%>
  layout "l/layouts/admin"

  # GET <%= route_url %>
  # GET <%= route_url %>.xml
  def index
    authorize! :manage, <%= class_name %>
    @<%= plural_table_name %> = <%= class_name %>

<% for attribute in attributes -%>
<% if attribute.type == :file -%>
    unless filter(:<%= attribute.name %>_file_name).blank?
      @<%= plural_table_name %> = @<%= plural_table_name %>.
        where("`<%= attribute.name %>_file_name` LIKE ?", "%#{filter(:<%= attribute.name %>_file_name)}%")
    end
<% else -%>
    unless filter(:<%= attribute.name %>).blank?
      @<%= plural_table_name %> = @<%= plural_table_name %>.
        where("`<%= attribute.name %>` LIKE ?", "%#{filter(:<%= attribute.name %>)}%")
    end
<% end -%>
<% end -%>
    
    @<%= plural_table_name %> = @<%= plural_table_name %>.order(sort_order) if sort_results?
    
    @<%= plural_table_name %> = @<%= plural_table_name %>.all.paginate page: params[:page]

    respond_to do |format|
      format.html
      format.json { render json: @<%= plural_table_name %>}
    end
  end

  # GET <%= route_url %>/1
  # GET <%= route_url %>/1.xml
  def show
    @<%= singular_table_name %> = <%= orm_class.find(class_name, "params[:id]") %>
    authorize! :read, @<%= singular_table_name %>


    respond_to do |format|
      format.html
      format.json { render json: @<%= singular_table_name %> }
    end
  end

  # GET <%= route_url %>/new
  # GET <%= route_url %>/new.xml
  def new
    @<%= singular_table_name %> = <%= orm_class.build(class_name) %>
    authorize! :create, @<%= singular_table_name %>

    respond_to do |format|
      format.html
    end
  end

  # GET <%= route_url %>/1/edit
  def edit
    @<%= singular_table_name %> = <%= orm_class.find(class_name, "params[:id]") %>
    authorize! :update, @<%= singular_table_name %>

    respond_to do |format|
      format.html
    end
  end

  # POST <%= route_url %>
  # POST <%= route_url %>.xml
  def create
    @<%= singular_table_name %> = <%= orm_class.build(class_name, "params[:#{singular_table_name}]") %>
    authorize! :create, @<%= singular_table_name %>

    respond_to do |format|
      if @<%= orm_instance.save %>
        format.html { redirect_to(<%= plural_table_name %>_path, notice: I18n.t('create.success') ) }
      else
        format.html { render action: "new" }
      end
    end
  end

  # PUT <%= route_url %>/1
  # PUT <%= route_url %>/1.xml
  def update
    @<%= singular_table_name %> = <%= orm_class.find(class_name, "params[:id]") %>
    authorize! :update, @<%= singular_table_name %>

    respond_to do |format|
      if @<%= orm_instance.update_attributes("params[:#{singular_table_name}]") %>
        format.html { redirect_to(<%= plural_table_name %>_path, notice: I18n.t('update.success') ) }
      else
        format.html { render action: "edit" }
      end
    end
  end

  # DELETE <%= route_url %>/1
  # DELETE <%= route_url %>/1.xml
  def destroy
    @<%= singular_table_name %> = <%= orm_class.find(class_name, "params[:id]") %>
    authorize! :destroy, @<%= singular_table_name %>
    @<%= orm_instance.destroy %>

    respond_to do |format|
      format.html { redirect_to :back, notice: I18n.t('delete.success') } 
      format.any  { head :ok }
    end
  end
end
