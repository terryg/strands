require 'migration_helpers'

class CreateLinkedNodes < ActiveRecord::Migration
  extend MigrationHelpers

  def self.up
    create_table "linked_nodes" do |t|
      t.column "from_node_id", :integer, :default => 0, :null => false
      t.column "to_node_id", :integer, :default => 0, :null => false
    end

    foreign_key(:linked_nodes, :from_node_id, :nodes)
    foreign_key(:linked_nodes, :to_node_id, :nodes)
  end
  
  def self.down
    drop_table :linked_nodes
  end
end
