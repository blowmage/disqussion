module Disqussion
  # The Forum holds the Disqus forum data, allowing the user to
  # iterate over the forums's threads.
  #
  # In Disqus, a forums is synonymous with a website or domain.
  class Forum

    # Creates a new Forum instance.
    #
    #  forums = Forum.new({ 'id' => '1234', 'shortname' => 'sn',
    #                       'name' => 'name' })
    #
    # @param [Hash] opts
    #   the values to create the Forum with
    def initialize(opts = {})
      @user_key  = opts['user_key']
      @id        = opts['id']
      @shortname = opts['shortname']
      @name      = opts['name']
    end

    # id: a unique alphanumeric string identifying this Forum object.
    # shortname: the unique string used in disqus.com URLs relating to this forum. For example, if the shortname is "bmb", the forum's community page is at http://bmb.disqus.com/.
    # name: a string for displaying the forum's full title, like "The Eyeball Kid's Blog".

    attr_accessor :user_key, :id, :shortname, :name

    # Retrieve the Disqus forum_api_key, finding the value  if neccessary.
    def forum_key
      @forum_key ||= retrieve_forum_key
    end

    # Returns all the forum's threads.
    # @return [Array<Thread>] a list of forums
    def threads
      @threads ||= retrieve_threads
    end

    # Clears the list of threads.
    def clear!
      @threads = nil
    end

    # Finds a Thread by a given URL. Useful of you want to get just
    # one Thread without retrieving all the threads for a forum.
    # Not reccomended, use find_thread_by_identifier instead.
    def find_thread_by_url(url)
      Thread.new(API.get_thread_by_url(forum_api_key, url).merge(default_hash))
    end

    # Create or retrieve a thread by an arbitrary identifying string of your choice.
    #
    #  disqus   = Disqussion.new
    #  blowmage = disqus['blowmage']
    #  new_thread = blowmage.find_thread_by_identifier(
    #    'new-disqus-thread', 'This is a new thread!')
    #  existing_thread = blowmage.find_thread_by_identifier(
    #    'existing-disqus-thread', 'This title won't get set...')
    #
    # @param [String] identifier
    #   a string of your choosing
    # @param [String] title
    #   the title of the thread to possibly be created
    #
    # @return [Thread]
    def find_thread_by_identifier(identifier, title)
      new_thread_hash = API.thread_by_identifier(forum_api_key, identifier, title)
      new_thread = Thread.new(new_thread_hash['thread'].merge(default_hash))
      @threads << new_thread if new_thread_hash['created'] && @threads
      new_thread
    end
    alias :create_thread :find_thread_by_identifier

    # Find a thread by either it's identifier or slug.
    #
    #  disqus       = Disqussion.new
    #  blowmage     = disqus['blowmage']
    def [](identifier)
      thread = threads.find { |t| t.id == identifier }
      thread = threads.find { |t| t.slug == identifier } if thread.nil?
      thread
    end

    def inspect
      "#<#{self.class}:#{self.object_id} (#{self.id}) #{self.shortname}>"
    end

    private

    def default_hash
      { 'user_key' => user_key, 'forum_key' => forum_key }
    end

    # Retrieves the forum's api_key from the API object.
    def retrieve_forum_key
      API.get_forum_api_key(user_key, id)
    end

    # Retrieves the Thread array from the API.
    def retrieve_threads
      API.get_thread_list(forum_key).map { |t| Thread.new(t.merge(default_hash)) }
    end

  end
end