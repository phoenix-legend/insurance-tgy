class JzgCarType < ActiveRecord::Migration
  def change
    create_table :jzg_car_types do |t|
      t.string :type_name
      t.string :name
      t.string :jzg_id
      t.string :group_name
      t.integer :parent_id
      t.integer :displacement
      t.string :style_year


      t.timestamps
      t.index :parent_id
      t.index :type_name

    end

  end
end
