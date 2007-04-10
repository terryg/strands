require 'migration_helpers'

class CreateComments < ActiveRecord::Migration
  extend MigrationHelpers

  def self.up
    create_table "comments", :force => true do |t|
      t.column "comment", :text, :default => ""
      t.column "created_at", :datetime, :null => false
      t.column "commentable_id", :integer, :default => 0, :null => false
      t.column "commentable_type", :string, :limit => 15, :default => "", :null => false
      t.column "user_id", :integer, :default => 0, :null => false
    end
    
    foreign_key(:comments, :user_id, :users)  
  end

  def self.down
    drop_table :comments
  end
end
