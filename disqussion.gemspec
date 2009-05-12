Gem::Specification.new do |s|
    s.platform          = Gem::Platform::RUBY
    s.name              = 'disqussion'
    s.version           = '0.1.0'
    s.author            = 'Mike Moore'
    s.email             = 'mike@blowmage.com'
    s.summary           = 'Disqussion is a library for using the Disqus API.'
    s.description       = 'Disqussion is a library for using the Disqus API. This is a longer description'
    s.files             = Dir.glob('lib/disqussion/*.rb') << 'lib/disqussion.rb'
    s.homepage          = 'http://github.com/blowmage/disqussion/wikis'
    s.require_path      = 'lib'
    s.test_files        = Dir.glob('tests/*.rb')
    s.has_rdoc          = true
    s.extra_rdoc_files  = ['README.rdoc']
end