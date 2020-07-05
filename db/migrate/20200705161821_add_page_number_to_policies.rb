class AddPageNumberToPolicies < ActiveRecord::Migration[6.0]
  def change
    add_column :policies, :page_number, :integer
  end
end
