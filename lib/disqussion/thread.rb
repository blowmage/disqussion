module Disqussion
  # The Thread holds the Disqus thread data, allowing the user to update
  # the data and to iterate over the thread's posts.
  #
  # In Disqus, a thread is synonymous with a page on a website.
  class Thread

    # Creates a new Thread instance from a hash of values.
    #
    #  thread = Thread.from_hash({'id' => '1234', title => 'title',
    #                             'slug' => '/some/path/here',
    #                             'allow_comments' => false,
    #                             'hidden' => false,
    #                             'created_at' => Time.now})
    #
    # @param [Hash] thread_hash
    #   the values to create the Forum with
    # @param [Forum] forum
    #   the forum the thread belongs to
    def self.from_hash(thread_hash, forum = nil)
      thread                = Thread.new
      thread.id             = thread_hash['id']
      thread.title          = thread_hash['title']
      thread.slug           = thread_hash['slug']
      thread.allow_comments = thread_hash['allow_comments']
      thread.hidden         = thread_hash['hidden']
      thread.created_at     = thread_hash['created_at']
      thread.forum = forum
      thread
    end

    # id: a unique alphanumeric string identifying this Thread object.
    # forum: the id for the forum this thread belongs to.
    # slug: the per-forum-unique string used for identifying this thread in disqus.com URLs relating to this thread. Composed of underscore-separated alphanumeric strings.
    # title: the title of the thread.
    # created_at: the UTC date this thread was created, in the format %Y-%m-%dT%H:%M.
    # allow_comments: whether this thread is open to new comments.
    # url: the URL this thread is on, if known.
    # identifier: the user-provided identifier for this thread, as in thread_by_identifier above (if available)

    attr_accessor :forum, :id, :title, :slug, :allow_comments, :hidden, :created_at
    alias :hidden? :hidden
    def visible
      !hidden
    end
    alias :visible? :visible

    # Returns all the thread's posts.
    # @return [Array<Post>] a list of posts
    def posts()
      @posts ||= retrieve_posts
    end

    # Returns all the thread's parent posts. Useful for navigating the
    # posts in a threaded manner.
    # @return [Array<Post>] a list of the parent posts
    def parent_posts()
      posts.find_all {|p| p.parent_post.nil? }
    end

    # Create a new post from a long list of method parameters. So sad.
    def create_post(message, author_name, author_email, author_url = nil, ip_address = nil, created_at = nil) # The identifier should be the URL if possible
      # law of demeter? pshaw!
      response = forum.session.api.create_post(forum.forum_key, id, message, author_name, author_email, author_url, ip_address, created_at)
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
      posts.find_by_id(identifier)
    end

    # Override inspect because of the circular dependencies. Otherwise
    # Discussion is unusable in irb.
    def inspect
      "#{id} - #{slug}"
    end

    def update
      forum.session.api.update_thread(forum.forum_key, id, title, slug, allow_comments)
    end

    private

    # def retrieve_posts()
    #   msg = forum.session.api.get_thread_posts(forum.forum_key, id)
    #   if msg && msg['succeeded']
    #     posts = []
    #     msg['message'].each do |post_hash|
    #       posts << Post.from_hash(post_hash, self)
    #     end
    #     # Monkey-patch helper methods
    #     def posts.find_by_id(id)
    #       find {|t| t.id == id }
    #     end
    #     #def post.add(message, author_name, author_email, author_url = nil, ip_address = nil, created_at = nil)
    #     #    # TODO: Can we get a reference to the thread object here?
    #     #    thread.create_post(message, author_name, author_email, author_url, ip_address, created_at)
    #     # end
    #     return posts
    #   end
    #   nil
    # end

    # Retrieves the Post array from the API.
    def retrieve_posts()
      msg = forum.session.api.get_thread_posts(forum.forum_key, id)
      if msg && msg['succeeded']
        posts = new_post_array()
        msg['message'].each do |post_hash|
          posts << Post.from_hash(post_hash, self)
        end
        return posts
      end
      nil
    end

    # Creates a new array with the proper methods monkey-patched in.
    def new_post_array()
      posts = []
      # Add reference to thread
      def posts.thread
        self # will this return the thread or the array?
      end

      # Add create new post helper method
      def post.add(message, author_name, author_email, author_url = nil, ip_address = nil, created_at = nil)
         # Use the reference to the thread added earlier
         thread.create_post(message, author_name, author_email, author_url, ip_address, created_at)
      end
      # Add finder helper methods
      def posts.find_by_id(id)
        find {|t| t.id == id }
      end
      return posts
    end
  end
end
