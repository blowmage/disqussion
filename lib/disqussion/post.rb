module Disqussion
  # The Post holds the Disqus post data, allowing the user to update
  # the data.
  #
  # In Disqus, a post is synonymous with a comment on website's page.
  class Post

    # Creates a new Post instance from a hash of values.
    #
    #  post = Post.from_hash({'id' => '1234', 'parent_post' => '123',
    #                         'message' => 'Awesoma powa!',
    #                         'shown' => true,
    #                         'created_at' => Time.now,
    #                         'author' => {'id' => '12345'
    #                                      'username' => 'someguy'
    #                                      'name' => 'Just some guy'
    #                                      'url' => 'http://someguy.com/'
    #                                      'email_hash' => '...'
    #                                      'has_avatar' => true}})
    #
    # @param [Hash] post_hash
    #   the values to create the Post with
    # @param [Thread] thread
    #   the thread the post belongs to
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

    # I don't think this works...
    # def is_anonymous
    #   post.is_anonymous
    # end

    alias :anonymous? :is_anonymous
    alias :shown? :shown

    # Gets the parent post for this post.
    def parent
      thread[parent_post]
    end

    # Gets the child posts to this post.
    def children
      thread.posts.find_all {|t| t.parent_post == id }
    end
  end
end
