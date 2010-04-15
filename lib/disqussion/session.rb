module Disqussion
  # The Session is intended to remember the user's Disqus key, as well
  # as serve as the top-most object holding all of the user's Forums.
  class Session

    # Set the default Disqus user_key to use for all future sessions.
    def self.default_user_key=(value)
      @@default_user_key = value
    end

    # Retrieve the default Disqus user_key.
    def self.default_user_key
      @@default_user_key ||= retrieve_default_user_key
    end

    # Retrieve the default Disqus user_key, raising InvalidKeyError if
    # there is no key found.
    def self.default_user_key!
      key = self.default_user_key
      throw InvalidKeyError if key.nil?
      key
    end

    attr_writer :user_key, :api

    # Retrieve the Disqus user_key, finding the default if neccessary.
    def user_key
      @user_key ||= Session.default_user_key!
    end
    # Retrieving or creating the API object for the Session.
    def api
      @api ||= API.new
    end
    alias :user_api_key :user_key
    alias :user_api_key= :user_key=

    # A new instance of Session.
    # @param [String, #user_key] Disqus user_key
    # @param [String, #api] API instance
    def initialize(user_key = nil, api = nil)
      user_key = @user_key if user_key
      @api = api if api
    end

    # Returns all the user's forums.
    # @return [Array<Forum>] a list of forums
    def forums
      @forums ||= retrieve_forums
    end

    # Clears the list of forums.
    def clear
      @forums = nil
    end

    # Find a forum by either it's identifier or shortname.
    #
    #  disqus     = Disqussion.new
    #  rubiverse  = disqus['123456']
    #  blowmage   = disqus['blowmage']
    def [](identifier)
      forum = forums.find_by_id(identifier)
      forum = forums.find_by_shortname(identifier) if forum.nil?
      forum
    end

    private

    # Retrieves the Forum array from the API.
    def retrieve_forums
      msg = api.get_forum_list(user_key)
      if msg && msg['succeeded']
        forums = []
        msg['message'].each do |forum_hash|
          forums << Forum.from_hash(forum_hash, self)
        end
        # Monkey-patch helper methods
        def forums.find_by_id(id)
          find {|f| f.id == id }
        end
        def forums.find_by_shortname(shortname)
          find {|f| f.shortname == shortname }
        end
        return forums
      end
      nil
    end

    # Retrieves the default Disqus user_key from the user's HOME
    # directory.
    def self.retrieve_default_user_key
      %w{.disqus .disqus_key .disqus_user_api_key}.each do |file|
        file = "#{ENV['HOME']}/#{file}"
        if File.exists? file
          return File.open(file, 'r').read
        end
      end
      nil
    end
  end

end
