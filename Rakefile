require 'rake'
require 'rake/clean'
require 'rake/testtask'

require 'rake/gempackagetask'
gemspec = eval(File.read('disqussion.gemspec'))

Rake::GemPackageTask.new(gemspec) do |p|
  p.gem_spec = gemspec
end

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'doc/rdoc'
  rdoc.title = "#{gemspec.name} #{gemspec.version}"
  rdoc.options << gemspec.rdoc_options.join(' ')
  rdoc.rdoc_files.include(gemspec.files)
  rdoc.main = 'README.textile'
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/**/test_*.rb'
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end

begin
  require 'reek/adapters/rake_task'
  Reek::RakeTask.new do |t|
    t.fail_on_error = true
    t.verbose = false
    t.source_files = 'lib/**/*.rb'
  end
rescue LoadError
  task :reek do
    abort "Reek is not available. In order to run reek, you must: sudo gem install reek"
  end
end

begin
  require 'roodi'
  require 'roodi_task'
  RoodiTask.new do |t|
    t.verbose = false
  end
rescue LoadError
  task :roodi do
    abort "Roodi is not available. In order to run roodi, you must: sudo gem install roodi"
  end
end

begin
  require 'flog'
  # require 'flog_task'
  # # This gives me "undefined method `flog_files' for #<Flog:0x5588a4>"
  # FlogTask.new do |t|
  #   t.dirs = ['lib']
  # end
  # Poor man's FlogTask
  task :flog do
    puts `flog lib`
  end
rescue LoadError
  task :flog do
    abort "Flog is not available. In order to run flog, you must: sudo gem install flog"
  end
end

task :default => :test
