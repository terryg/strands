require 'migration_helpers'

class CreateFeeds < ActiveRecord::Migration
  extend MigrationHelpers

  def self.up
    create_table "feeds" do |t|
      t.column "url", :string, :default => "", :null => false
      t.column "name", :string, :default => "", :null => true
      t.column "user_id", :integer, :default => 0, :null => false
    end

    foreign_key(:feeds, :user_id, :users)
  end
  
  def self.down
    drop_table :feeds
  end
end
