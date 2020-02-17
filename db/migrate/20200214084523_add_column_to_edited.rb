class AddColumnToEdited < ActiveRecord::Migration[5.2]
  def change
    add_column :editeds, :user_id, :integer, after: :id
    add_column :editeds, :annotation_id, :integer, after: :user_id
    remove_column :editeds, :category_id, :integer
    remove_column :editeds, :folder_name, :string
    remove_column :editeds, :state, :integer

  end
end
