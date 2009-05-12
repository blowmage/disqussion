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
  def self.new(user_key = nil, api = nil)
    Session.new(user_key, api)
  end
end