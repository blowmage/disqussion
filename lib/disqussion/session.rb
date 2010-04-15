module Disqussion
  # The Session is intended to remember the user's Disqus key, as well
  # as serve as the top-most object holding all of the user's Forums.
  class Session

    attr_accessor :user_key

    # A new instance of Session.
    # @param [String, #user_key] Disqus user_key
    def initialize(user_key = nil)
      @user_key = user_key if user_key
    end

    # Returns all the user's forums.
    # @return [Array<Forum>] a list of forums
    def forums
      @forums ||= retrieve_forums
    end

    # Clears the list of forums.
    def clear!
      @forums.clear! if @forums
      @forums = nil
    end

    # Find a forum by either it's identifier or shortname.
    #
    #  disqus     = Disqussion.new
    #  rubiverse  = disqus['123456']
    #  blowmage   = disqus['blowmage']
    def [](identifier)
      forum = forums.find {|f| f.id == identifier }
      forum = forums.find {|f| f.shortname == identifier } if forum.nil?
      forum
    end

    private

    def default_hash
      { 'user_key' => user_key }
    end

    # Retrieves the Forum array from the API.
    def retrieve_forums
      API.get_forum_list(user_key).map { |f| Forum.new(f.merge(default_hash)) }
    end

  end

end
