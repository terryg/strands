class AddTracker < ActiveRecord::Migration
  def self.up
    create_table "node_comment_statistics" do |t|
      t.column "node_id", :integer, :default => 0, :null => false
      t.column "last_comment_created_at", :datetime
      t.column "last_comment_user_id", :integer, :default => 0, :null => false
      t.column "comment_count", :integer
    end
    
    create_table "history" do |t|
      t.column "user_id", :integer, :default => 0, :null => false
      t.column "node_id", :integer, :default => 0, :null => false
      t.column "viewed_at", :datetime
    end

    Node.find(:all).each do |n|
      last_comment = n.comments.last
      if last_comment.nil?
        execute("INSERT INTO node_comment_statistics (node_id, last_comment_created_at, last_comment_user_id, comment_count) VALUES (#{n.id}, '#{n.created_at}', #{n.user_id}, 0)")      
      else
        execute("INSERT INTO node_comment_statistics (node_id, last_comment_created_at, last_comment_user_id, comment_count) VALUES (#{n.id}, '#{last_comment.created_at}', #{last_comment.user_id}, #{n.comments.size})")
      end
    end
  end

  def self.down
    drop_table :node_comment_statistics
    drop_table :history
  end
end
