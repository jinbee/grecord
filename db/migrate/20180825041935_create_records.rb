class CreateRecords < ActiveRecord::Migration[5.1]
  def change
    create_table :records do |t|
      t.timestamp     :recorddate
      t.integer      :outgo
      t.text    :purpose
      t.integer  :count
      t.text   :routine
      t.string  :result
      t.integer      :maxrate
      t.references :user, foreign_key: true
      t.references :sgame, foreign_key: true
      t.timestamps
    end
  end
end
