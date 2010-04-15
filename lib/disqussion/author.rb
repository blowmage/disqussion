module Disqussion
  # The Author holds the Disqus author data.
  class Author
    
    # Creates a new Author instance from a hash of values.
    #
    #  post = Author.from_hash({'id' => '12345'
    #                           'username' => 'someguy'
    #                           'name' => 'Just some guy'
    #                           'url' => 'http://someguy.com/'
    #                           'email_hash' => '...'
    #                           'has_avatar' => true})
    #                         
    # @param [Hash] Author
    #   the values to create the Post with
    # @param [Post] post
    #   the post the author belongs to
    def initialize(opts = {})
      @id           = opts['id']
      @username     = opts['username']
      @name         = opts.has_key?('display_name') ? opts['display_name'] : opts['name']
      @url          = opts['url']
      @email_hash   = opts['email_hash']
      @has_avatar   = opts['has_avatar']
      @is_anonymous = opts.has_key?('display_name')
    end
    
    attr_accessor :id, :username, :name, :url, :email_hash, :has_avatar, :is_anonymous
    alias :avatar? :has_avatar
    alias :anonymous? :is_anonymous
    
  end
end
