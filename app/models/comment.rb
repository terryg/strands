class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :node
    
  def after_create
   connection.execute("UPDATE node_comment_statistics SET last_comment_created_at = '#{self.created_at}', last_comment_user_id = #{self.user_id}, comment_count = #{self.node.comments.size} WHERE node_id = #{self.node_id}")
  end

end