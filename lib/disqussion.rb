require 'disqussion/api'
require 'disqussion/session'
require 'disqussion/forum'
require 'disqussion/thread'
require 'disqussion/post'
require 'disqussion/author'

# This module namespaces the Disqussion library and allows for an easier creation of a Disqussion::Session object.

module Disqussion
  MAJOR, MINOR, TINY  = 0, 1, 0
  VERSION = [ MAJOR, MINOR, TINY ].join( "." )
  
  # Shortcut for Disqussion::Session.new(user_key, api)
  def self.new(user_key = nil)
    Session.new(user_key || default_user_key)
  end

  # Retrieves the default Disqus user_key from the user's HOME
  # directory.
  def self.default_user_key
    %w{.disqus .disqus_key .disqus_user_api_key}.each do |file|
      file = "#{ENV['HOME']}/#{file}"
      if File.exists? file
        return File.open(file, 'r').read
      end
    end
    nil
  end
end