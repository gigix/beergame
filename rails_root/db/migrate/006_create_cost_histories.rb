class CreateCostHistories < ActiveRecord::Migration
  def self.up
    create_table :cost_histories do |t|
      t.integer :role_id
      t.float :amount
      t.integer :at_week 
      t.timestamps
    end
  end

  def self.down
    drop_table :cost_histories
  end
end
