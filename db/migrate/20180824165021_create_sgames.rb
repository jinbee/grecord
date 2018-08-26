class CreateSgames < ActiveRecord::Migration[5.1]
  def change
    create_table :sgames do |t|
      t.string :gname
      t.references :user, foreign_key: true
      t.string :status
      t.timestamps
    end
  end
end
