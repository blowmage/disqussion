module Disqussion
  class Thread
    
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
    
    attr_accessor :forum, :id, :title, :slug, :allow_comments, :hidden, :created_at
    alias :hidden? :hidden
    def visible
      !hidden
    end
    alias :visible? :visible
    
    def posts()
      @posts ||= retrieve_posts
    end
    
    def parent_posts()
      posts.find_all {|p| p.parent_post.nil? }
    end
    
    def create_post(message, author_name, author_email, author_url = nil, ip_address = nil, created_at = nil) # The identifier should be the URL if possible
      response = forum.session.api.create_post(forum.forum_key, id, message, author_name, author_email, author_url, ip_address, created_at)
      raise Error(response['message']) if response['succeeded'].nil?
      new_post = Post.from_hash(response['post'], self)
      @posts << new_post if @posts
      new_post
    end
    alias :add_post :create_post
    alias :new_post :create_post
    alias :<< :create_post
    
    def [](identifier)
      posts.find_by_id(identifier)
    end
    
    def inspect
      "#{id} - #{slug}"
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
