module Disqussion
  class Post
    
    def self.from_hash(post_hash, thread = nil)
      post              = Post.new
      post.id           = post_hash['id']
      post.message      = post_hash['message']
      post.parent_post  = post_hash['parent_post']
      post.shown        = post_hash['shown']
      post.created_at   = post_hash['created_at']
      post.author       = Author.from_hash(post_hash['is_anonymous'] ? post_hash['anonymous_author'] : post_hash['author'], post)
      post.thread = thread
      post
    end
    
    attr_accessor :thread, :id, :message, :parent_post, :shown, :author, :created_at
    
    def is_anonymous
      post.is_anonymous
    end
    
    alias :anonymous? :is_anonymous
    alias :shown? :shown
    
    def parent
      thread[parent_post]
    end
    
    def children
      thread.posts.find_all {|t| t.parent_post == id }
    end
  end
end
