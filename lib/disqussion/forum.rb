module Disqussion
  # The Forum holds the Disqus forum data, allowing the user to
  # iterate over the forums's threads.
  #
  # In Disqus, a forums is synonymous with a website or domain.
  class Forum

    # Creates a new Forum instance from a hash of values.
    #
    #  forums = Forum.from_hash({:id => '1234', shortname => 'sn',
    #                            :name => 'name'})
    #
    # @param [Hash] forum_hash
    #   the values to create the Forum with
    # @param [Session] session
    #   the session the forum belongs to
    def self.from_hash(forum_hash, session = nil)
      forum           = Forum.new
      forum.id        = forum_hash['id']
      forum.shortname = forum_hash['shortname']
      forum.name      = forum_hash['name']
      forum.session   = session
      forum
    end

    # id: a unique alphanumeric string identifying this Forum object.
    # shortname: the unique string used in disqus.com URLs relating to this forum. For example, if the shortname is "bmb", the forum's community page is at http://bmb.disqus.com/.
    # name: a string for displaying the forum's full title, like "The Eyeball Kid's Blog".

    attr_accessor :session, :id, :shortname, :name
    alias :short_name :shortname
    alias :short_name= :shortname=

    # Retrieve the Disqus forum_api_key, finding the value  if neccessary.
    def forum_key()
      @forum_key ||= retrieve_forum_key
    end

    # Returns all the forum's threads.
    # @return [Array<Thread>] a list of forums
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

    # Finds a Thread by a given URL. Useful of you want to get just
    # one Thread without retrieving all the threads for a forum.
    def find_thread_by_url(url)
      return @threads.find_by_slug(url) if @threads
      response = session.api.get_thread_by_url(forum_api_key, url)
      raise Error(response['message']) if response['succeeded'].nil?
      Thread.from_hash(response['thread'], self)
    end

    # Find a thread by either it's identifier or slug.
    #
    #  disqus       = Disqussion.new
    #  blowmage     = disqus['blowmage']
    def [](identifier)
      thread = threads.find_by_id(identifier)
      thread = threads.find_by_slug(identifier) if thread.nil?
      thread
    end

    # Override inspect because of the circular dependencies. Otherwise
    # Discussion is unusable in irb.
    def inspect
      "#{id} - #{shortname}"
    end

    private

    # Retrieves the forum's api_key from the API object.
    def retrieve_forum_key()
      msg = session.api.get_forum_api_key(session.user_key, id)
      if msg && msg['succeeded']
        return msg['message']
      end
      nil
    end

    # Retrieves the Thread array from the API.
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