module Disqussion
  class Forum
    
    def self.from_hash(forum_hash, session = nil)
      forum           = Forum.new
      forum.id        = forum_hash['id']
      forum.shortname = forum_hash['shortname']
      forum.name      = forum_hash['name']
      forum.session   = session
      forum
    end
    
    attr_accessor :session, :id, :shortname, :name
    alias :short_name :shortname
    alias :short_name= :shortname=
    
    def forum_key()
      @forum_key ||= retrieve_forum_key
    end
    
    def threads()
      @threads ||= retrieve_threads
    end
    
    def create_thread(identifier, title) # The identifier should be the URL if possible
      response = session.api.thread_by_identifier(forum_api_key, identifier, title)
      raise Error(response['message']) if response['succeeded'].nil?
      new_thread = Thread.from_hash(response['thread'], self)
      @threads << new_thread if @threads
      new_thread
    end
    alias :add_thread :create_thread
    alias :new_thread :create_thread
    alias :<< :create_thread
    
    def find_thread_by_url(url)
      response = session.api.get_thread_by_url(forum_api_key, url)
      raise Error(response['message']) if response['succeeded'].nil?
      Thread.from_hash(response['thread'], self)
    end
    
    def [](identifier)
      thread = threads.find_by_id(identifier)
      thread = threads.find_by_slug(identifier) if thread.nil?
      thread
    end
    
    def inspect
      "#{id} - #{shortname}"
    end
    
    private
    
    def retrieve_forum_key()
      msg = session.api.get_forum_api_key(session.user_key, id)
      if msg && msg['succeeded']
        return msg['message']
      end
      nil
    end
    
    def retrieve_threads()
      msg = session.api.get_thread_list(forum_key)
      if msg && msg['succeeded']
        threads = []
        msg['message'].each do |thread_hash|
          threads << Thread.from_hash(thread_hash, self)
        end
        # Monkey-patch helper methods
        def threads.find_by_id(id)
          find {|t| t.id == id }
        end
        def threads.find_by_slug(slug)
          find {|t| t.slug == slug }
        end
        #def threads.add(identifier, title)
        #    # TODO: Can we get a reference to the forum object here?
        #    forum.create_thread(identifier, title)
        # end
        return threads
      end
      nil
    end
  end
end