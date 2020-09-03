class CreatePolicies < ActiveRecord::Migration[6.0]
  def change
    create_table :policies do |t|
      t.string :holder
      t.string :agency
      t.jsonb :payload

      t.timestamps
    end
  end
end
