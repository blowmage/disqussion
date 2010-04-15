module Disqussion
  # The Post holds the Disqus post data.
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

    # id: a unique alphanumeric string identifying this Post object.
    # forum: the id for the forum this post belongs to.
    # thread: the id for the thread this post belongs to.
    # created_at: the UTC date this post was created, in the format %Y-%m-%dT%H:%M.
    # message: the contents of the post, such as "First post".
    # parent_post: the id of the parent post, if any
    # shown: whether the post is currently visible or not.
    # is_anonymous: whether the comment was left anonymously, as opposed to a registered Disqus account.
    # anonymous_author: present only when is_anonymous is true. An object containing these fields:
    #  name: the display name of the commenter
    #  url: their optionally provided homepage
    #  email_hash: md5 of the author's email address
    # author: present only when is_anonymous is false. An object containing these fields:
    #  id: the unique id of the commenter's Disqus account
    #  username: the author's username
    #  display_name: the author's full name, if provided
    #  url: their optionally provided homepage
    #  email_hash: md5 of the author's email address
    #  has_avatar: whether the user has an avatar on disqus.com

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
