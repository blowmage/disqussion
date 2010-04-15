module Disqussion
  # The Thread holds the Disqus thread data, allowing the user to update
  # the data and to iterate over the thread's posts.
  #
  # In Disqus, a thread is synonymous with a page on a website.
  class Thread

    # Creates a new Thread instance.
    #
    #  thread = Thread.new({ 'id' => '1234', title => 'title',
    #                        'slug' => '/some/path/here',
    #                        'allow_comments' => false,
    #                        'hidden' => false,
    #                        'created_at' => Time.now })
    #
    # @param [Hash] opts
    #   the values to create the Forum with
    def initialize(opts = {})
      @user_key       = opts['user_key']
      @forum_key      = opts['forum_key']
      @forum          = opts['forum']
      @id             = opts['id']
      @title          = opts['title']
      @slug           = opts['slug']
      @allow_comments = opts['allow_comments']
      @hidden         = opts['hidden']
      @created_at     = opts['created_at']
    end

    # id: a unique alphanumeric string identifying this Thread object.
    # forum: the id for the forum this thread belongs to.
    # slug: the per-forum-unique string used for identifying this thread in disqus.com URLs relating to this thread. Composed of underscore-separated alphanumeric strings.
    # title: the title of the thread.
    # created_at: the UTC date this thread was created, in the format %Y-%m-%dT%H:%M.
    # allow_comments: whether this thread is open to new comments.
    # url: the URL this thread is on, if known.
    # identifier: the user-provided identifier for this thread, as in thread_by_identifier above (if available)

    attr_accessor :user_key, :forum_key, :forum, :id, :title, :slug, :allow_comments, :hidden, :created_at
    alias :hidden? :hidden
    def visible
      !hidden
    end
    alias :visible? :visible

    # Returns all the thread's posts.
    # @return [Array<Post>] a list of posts
    def posts
      @posts ||= retrieve_posts
    end

    # Clears the list of posts.
    def clear!
      @posts = nil
    end

    # Returns all the thread's parent posts. Useful for navigating the
    # posts in a threaded manner.
    # @return [Array<Post>] a list of the parent posts
    def parent_posts
      posts.find_all {|p| p.parent_post.nil? }
    end

    # Create a new post from a long list of method parameters. So sad.
    # The identifier should be the URL if possible
    def create_post(message, author_name, author_email, author_url = nil, ip_address = nil, created_at = nil)
      new_post_hash = API.create_post(forum_key, id, message, author_name, author_email, author_url, ip_address, created_at)
      new_post = Post.new(new_post_hash.merge(default_hash))
      @posts << new_post if @posts
      new_post
    end
    alias :add_post :create_post
    alias :new_post :create_post
    alias :<< :create_post

    # Find a post by either it's identifier.
    #
    #  disqus   = Disqussion.new
    #  page     = disqus['blowmage']['announcing-disqussion']
    def [](identifier)
      posts.find {|t| t.id == identifier }
    end

    def update
      API.update_thread(forum_key, id, title, slug, allow_comments)
    end

    # Gets the parent post of a post.
    def parent_of(post)
      posts.find {|t| t.id == post.parent_post }
    end

    # Gets the child posts of a post.
    def children_of(post)
      posts.find_all {|t| t.parent_post == post.id }
    end

    def inspect
      "#<#{self.class}:#{self.object_id} (#{self.id}) #{self.title}>"
    end

    private

    def default_hash
      { 'user_key' => user_key, 'forum_key' => forum_key }
    end

    # Retrieves the Post array from the API.
    def retrieve_posts
      API.get_thread_posts(forum_key, id).map { |p| Post.new(p.merge(default_hash)) }
    end
  end
end
