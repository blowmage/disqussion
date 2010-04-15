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
    def self.from_hash(author_hash, post = nil)
      author              = Author.new
      author.id           = author_hash['id']
      author.username     = author_hash['username']
      author.name         = author_hash.has_key?('display_name') ? author_hash['display_name'] : author_hash['name']
      author.url          = author_hash['url']
      author.email_hash   = author_hash['email_hash']
      author.has_avatar   = author_hash['has_avatar']
      author.is_anonymous = author_hash.has_key?('display_name')
      author.post = post
      author
    end
    
    attr_accessor :post, :id, :username, :name, :url, :email_hash, :has_avatar, :is_anonymous
    alias :avatar? :has_avatar
    alias :anonymous? :is_anonymous
    
  end
end
