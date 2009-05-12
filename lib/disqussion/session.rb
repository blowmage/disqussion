module Disqussion
  class Session
    
    def self.default_user_key=(value)
      @@default_user_key = value
    end
    
    def self.default_user_key()
      @@default_user_key ||= retrieve_default_user_key
    end
    
    def self.default_user_key!()
      key = self.default_user_key
      throw InvalidKeyError if key.nil?
      key
    end
    
    attr_writer :user_key, :api
    def user_key()
      @user_key ||= Session.default_user_key!
    end
    def api()
      @api ||= API.new
    end
    alias :user_api_key :user_key
    alias :user_api_key= :user_key=
    
    def initialize(user_key = nil, api = nil)
      user_key = @user_key if user_key
      @api = api if api
    end
    
    def forums()
      @forums ||= retrieve_forums
    end
    
    def clear()
      @forums = nil
    end
    
    def [](identifier)
      forum = forums.find_by_id(identifier)
      forum = forums.find_by_shortname(identifier) if forum.nil?
      forum
    end
    
    private
    
    def retrieve_forums()
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
    
    def self.retrieve_default_user_key()
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
