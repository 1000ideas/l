class Create<%= singular_table_name.capitalize %>Drafts < ActiveRecord::Migration
  def change
    create_table :<%= singular_table_name %>_drafts do |t|
    	t.integer :<%= singular_table_name %>_id
    <% attributes.each do |a| %>
    	t.<%= a.type %> :<%= a.name %><% end %>
      t.timestamps
    end
  end

end 