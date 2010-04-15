# The Disqussion library is a Ruby wrapper for the Disqus web API.
#
# Author::    Mike Moore  (mailto:mike@blowmage.com)
# License::   Distributes under the same terms as Ruby

require 'net/http'
require 'uri'
require 'json'

# This class has the responsibility for connecting to the Disqus web services 
# over HTTP and returning the JSON result of each service call as a Hash.

module Disqussion
  class API
    
    # Creates a new post on the given forum and thread.
    # Does not check against spam filters or ban list.
    # This is intended to allow automated importing of comments.
    #
    # ==== Arguments
    #
    # * forum_key:     the blah blah blah
    # * thread_id:     the thread to post to
    # * message:       the content of the post
    # * author_name:   the post creator's name
    # * author_email:  their email address
    # * parent_post:   the id of the parent post _Optional_
    # * created_at:    the date this post was created _Optional_
    # * author_url:    the author's homepage _Optional_
    # * ip_address:    their IP address _Optional_
    #
    # ==== Return
    #
    # A hash representing the post object just created.
    #
    # ==== Example
    #
    #  api = Disqussion::API.new
    #  new_post = api.create_post('4kFsdGVkX178GElQi7xINR6NRVw5gjJxIJUB9lkVRLWUzWdqgAt3tqXRXu6nfsrr', 
    #    'f9FsdGVkX19KNR9sFf3sAgoWC2tYstpoPlwsB3cb1RjbPJSstQm95kLoNC9dExyP', 
    #    'This is a new message', 'Mike Moore', 'mike@blowmage.com', 'http://blowmage.com/', 
    #    nil, '127.0.0.1', Time.now)
    #
    def create_post(forum_key, thread_id, message, author_name, author_email, 
        author_url = nil, parent_post = nil, ip_address = nil, created_at = nil)
      params = {
        'forum_key' => forum_key,
        'thread_id' => thread_id,
        'message' => message,
        'author_name' => author_name,
        'author_email' => author_email
      }
      params['author_url'] = author_url if author_url
      params['parent_post'] = parent_post if parent_post
      params['ip_address'] = ip_address if ip_address
      params['created_at'] = created_at.getutc.strftime('%Y-%m-%dT%H:%M') if created_at && created_at.is_a?(Time)
      post 'create_post', params
    end
    
    # get_forum_list:
    # 
    # ==== Arguments
    #
    # * user_api_key: The blah blah blah
    # 
    # ==== Return
    #
    # A list of objects representing all forums the user owns.
    #
    def get_forum_list(user_api_key)
      get 'get_forum_list', { 'user_api_key' => user_api_key }
    end
    
    # Retrieves the API Key for a given Forum.
    # The API Key is needed for other Disqus API calls.
    # 
    # ==== Arguments
    #
    # * user_api_key: The blah blah blah
    # * forum_id:     The unique id of the forum.
    # 
    # ==== Return
    #
    # A string which is the Forum API Key for the given forum.
    #
    def get_forum_api_key(user_api_key, forum_id)
      get 'get_forum_api_key', { 'user_api_key' => user_api_key, 'forum_id' => forum_id }
    end
    
    # get_thread_list:
    # 
    # ==== Arguments
    #
    # * "forum_api_key", the blah blah blah
    # 
    # ==== Return
    #
    # A list of all threads belonging to the given forum.
    def get_thread_list(forum_api_key)
      get 'get_thread_list', { 'forum_api_key' => forum_api_key }
    end
    
    # get_num_posts:
    # 
    # ==== Arguments
    #
    # * "forum_api_key", the blah blah blah
    # * "thread_ids", an array of the thread IDs belonging to the given forum.
    # 
    # ==== Return
    #
    # An object mapping each thread_id to a list of two numbers.
    # The first number is the number of visible comments on on the thread;
    # this would be useful for showing users of the site (e.g., "5 Comments").
    # The second number is the total number of comments on the thread.
    # These numbers are different because some forums require moderator approval,
    # some messages are flagged as spam, etc.
    def get_num_posts(forum_api_key, thread_ids)
      get 'get_num_posts', { 'forum_api_key' => forum_api_key , 'thread_ids' => thread_ids.join(',')}
    end
    
    # get_thread_by_url:
    # 
    # ==== Arguments
    #
    # * "forum_api_key", the blah blah blah
    # * "url", the URL to check for an associated thread.
    # 
    # ==== Return
    #
    # A thread object if one was found, otherwise null.
    # Only finds threads associated with the given forum.
    # Note that there is no one-to-one mapping between threads and URLs:
    # a thread will only have an associated URL if it was automatically created
    # by Disqus javascript embedded on that page.
    # Therefore, we recommend using thread_by_identifier whenever possible,
    # and this method is provided mainly for handling comments from before your forum was using the API.
    def get_thread_by_url(forum_api_key, url)
      get 'get_thread_by_url', { 'forum_api_key' => forum_api_key, 'url' => url }
    end
    
    # get_thread_posts:
    # 
    # ==== Arguments
    #
    # * "forum_api_key", the blah blah blah
    # * "thread_id", the ID of a thread belonging to the given forum.
    # 
    # ==== Return
    #
    # A list of objects representing all posts belonging to the given forum.
    def get_thread_posts(forum_api_key, thread_id)
      get 'get_thread_posts', { 'forum_api_key' => forum_api_key, 'thread_id' => thread_id }
    end
    
    # Create or retrieve a thread by an arbitrary identifying string of your choice.
    # For example, you could use your local database's ID for the thread.
    # This method allows you to decouple thread identifiers from the URLs on which they might be appear.
    # (Disqus would normally use a thread's URL to identify it,
    # which is problematic when URLs do not uniquely identify a resource.)
    # If no thread yet exists for the given identifier (paired with the forum), one will be created.
    # 
    # ==== Arguments
    #
    # * "forum_api_key", the blah blah blah
    # * "title", the title of the thread to possibly be created; and "identifier", a string of your choosing (see Action).
    # 
    # ==== Return
    #
    # An object with two keys: "thread", which is the thread object corresponding to the identifier;
    # and "created", which indicates whether the thread was created as a result of this method call.
    # If created, it will have the specified title.
    def thread_by_identifier(forum_api_key, identifier, title)
      post 'thread_by_identifier', { 'forum_api_key' => forum_api_key, 'identifier' => identifier, 'title' => title }
    end
    
    # Updates a thread's attributes.
    # 
    # ==== Required Arguments
    #
    # * "forum_api_key", the forum key
    # * "thread_id", the ID of a thread belonging to the given forum
    # 
    # ==== Optional Arguments
    #
    # * "title", the title of the thread
    # * "slug", the per-forum-unique string used for identifying this thread in disqus.com URLs relating to this thread. Composed of underscore-separated alphanumeric strings
    # * "allow_comments", whether this thread is open to new comments
    # 
    # ==== Return
    #
    # An empty success message.
    def update_thread(forum_api_key, thread_id, title = nil, slug = nil, allow_comments = nil)
      params = { 'forum_api_key' => forum_api_key, 'thread_id' => thread_id }
      params['title'] = title if title
      params['slug'] = slug if slug
      params['allow_comments'] = allow_comments if allow_comments
      # Where do we check the response code?
      post 'update_thread', params
    end
    
    private
    
    def get(method, params = {})
      uri = URI.parse("http://disqus.com/api/#{method}/?#{hash_to_query(params)}")
      # should we raise an error is response.code != 200?
      # or if JSON(response.body)['code'] != 'ok'
      JSON.parse(Net::HTTP.get(uri))
    end
    
    def post(method, params = {})
      uri = URI.parse("http://disqus.com/api/#{method}/")
      # should we raise an error is response.code != 200?
      # or if JSON(response.body)['code'] != 'ok'
      JSON.parse(Net::HTTP.post_form(uri, params).body)
    end

    def hash_to_query(hsh)
      hsh.map { |k,v| "#{URI.escape(k)}=#{URI.escape(v)}" }.join('&')
    end
  end
end
