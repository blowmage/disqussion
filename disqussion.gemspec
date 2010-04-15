# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'disqussion'

Gem::Specification.new do |s|
    s.platform          = Gem::Platform::RUBY
    s.name              = 'disqussion'
    s.version           = Disqussion::VERSION
    s.author            = 'Mike Moore'
    s.email             = 'mike@blowmage.com'
    s.summary           = 'Disqus API made easy.'
    s.description       = 'Disqussion is a library for using the Disqus API.'
    s.homepage          = 'http://wiki.github.com/blowmage/disqussion/'
    s.files             = Dir.glob('lib/**/*') + %w{README.textile}
    s.require_paths     = ['lib']
    s.test_files        = Dir.glob('test/**/*')
    s.has_rdoc          = true
    s.extra_rdoc_files  = ['README.textile']
    s.rdoc_options      << '--charset=UTF-8' << '--title' << "#{s.name} #{s.version}: #{s.summary}" <<
                           '--main' << 'README.textile' <<'--line-numbers' << '--inline-source'
    s.extra_rdoc_files  = ['README.textile']
    s.add_dependency    'json'
end