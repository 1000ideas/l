module L
  module FilterHelper

    def filter(name)
      params[:filter][name] unless params[:filter].blank?
    end

    def sort_order(table_name = nil)
      return '' if params[:sort].blank?
      regex = %r{^([a-z_]*)_(asc|desc)$}
      return '' unless params[:sort].match regex
      name = $1
      type = $2.upcase
      table_name.blank? ? "`#{name}` #{type}" : "`#{table_name}`.`#{name}` #{type}"
    end

    def sort_results?
      ! params[:sort].blank?
    end

  end
end
