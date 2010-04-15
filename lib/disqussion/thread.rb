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

    attr_accessor :user_key, :forum_key, :id, :title, :slug, :allow_comments, :hidden, :created_at
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
    def create_post(message, author_name, author_email, author_url = nil, ip_address = nil, created_at = nil) # The identifier should be the URL if possible
      # law of demeter? pshaw!
      response = API.create_post(forum_key, id, message, author_name, author_email, author_url, ip_address, created_at)
      raise Error(response['message']) if response['succeeded'].nil?
      new_post = Post.from_hash(response['post'], self)
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
      [post.parent_post]
    end

    # Gets the child posts of a post.
    def children_of(post)
      posts.find_all {|t| t.parent_post == post.id }
    end

    private

    # Retrieves the Post array from the API.
    def retrieve_posts
      msg = API.get_thread_posts(forum_key, id)
      if msg && msg['succeeded']
        posts = []
        msg['message'].each do |post_hash|
          posts << Post.new(post_hash)
        end
        return posts
      end
      nil
    end
  end
end
