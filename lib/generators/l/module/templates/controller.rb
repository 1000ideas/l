class <%= controller_class_name %>Controller < ApplicationController

  def index
    authorize! :read, <%= class_name %>
    @<%= plural_table_name %> = <%= class_name %>
      .paginate page: params[:page]

    respond_to do |format|
      format.html
      format.json { render json: @<%= plural_table_name %>}
    end
  end

  def show
    @<%= singular_table_name %> = <%= orm_class.find(class_name, "params[:id]") %>
    authorize! :read, @<%= singular_table_name %>

    respond_to do |format|
      format.html
      format.json { render json: @<%= singular_table_name %> }
    end
  end

end
