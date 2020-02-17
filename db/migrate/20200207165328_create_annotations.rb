class CreateAnnotations < ActiveRecord::Migration[5.2]
  def change
    create_table :annotations do |t|
      t.string :path
      t.integer :category_id
      t.string :folder_name
      t.string :information
      t.integer :state
      t.timestamps
    end
  end
end
