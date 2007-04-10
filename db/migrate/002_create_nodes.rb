require 'migration_helpers'

class CreateNodes < ActiveRecord::Migration
  extend MigrationHelpers

  def self.up
    create_table "nodes", :force => true do |t|
      t.column :label, :string, :limit => 50, :default => ""
      t.column :body, :text, :default => ""
      t.column :extended, :text, :default => ""
      t.column :excerpt, :text, :default => ""
      t.column :start_date, :datetime
      t.column :end_date, :datetime
      t.column :address, :string, :default => ""
      t.column :city, :string, :default => ""
      t.column :statecode, :string, :default => ""
      t.column :postcode, :string, :default => ""
      t.column :countrycode, :string, :default => ""
      t.column :user_id, :integer, :default => 0, :null => false
      t.column :created_at, :datetime
    end
    
    foreign_key(:nodes, :user_id, :users)
  end

  def self.down
    drop_table :nodes
  end
end
