class CreateClassifiers < ActiveRecord::Migration[5.2]
  def change
    create_table :classifiers do |t|
      t.integer :user_id
      t.integer :annotation_id
      t.string :path
      t.string :information
      t.timestamps
    end
  end
end
