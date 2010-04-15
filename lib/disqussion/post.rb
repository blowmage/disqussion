module Disqussion
  # The Post holds the Disqus post data.
  #
  # In Disqus, a post is synonymous with a comment on website's page.
  class Post

    # Creates a new Post instance.
    #
    #  post = Post.new({ 'id' => '1234', 'parent_post' => '123',
    #                    'message' => 'Awesoma powa!',
    #                    'shown' => true,
    #                    'created_at' => Time.now,
    #                    'author' => { 'id' => '12345'
    #                                  'username' => 'someguy'
    #                                  'name' => 'Just some guy'
    #                                  'url' => 'http://someguy.com/'
    #                                  'email_hash' => '...'
    #                                  'has_avatar' => true } })
    #
    # @param [Hash] opts
    #   the values to create the Post with
    def initialize(opts = {})
      @forum        = opts['forum']
      @thread       = opts['thread']
      @id           = opts['id']
      @message      = opts['message']
      @parent_post  = opts['parent_post']
      @shown        = opts['shown']
      @is_anonymous = opts['is_anonymous']
      @created_at   = opts['created_at']
      @author       = Author.new(opts['is_anonymous'] ? opts['anonymous_author'] : opts['author'])
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

    attr_accessor :forum, :thread, :id, :message, :parent_post, :shown, :is_anonymous, :author, :created_at

    alias :anonymous? :is_anonymous
    alias :shown? :shown
  end
end
