class Comment < ActiveRecord::Base
  belongs_to :user
    
  def after_create
    if commentable_type == 'Node'
      node = Node.find(commentable_id)
      count = node.comments.size
      connection.execute("UPDATE node_comment_statistics SET last_comment_created_at = '#{self.created_at}', last_comment_user_id = #{self.user_id}, comment_count = #{count} WHERE node_id = #{self.commentable_id}")
    end
  end

end