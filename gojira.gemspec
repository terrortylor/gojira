lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = 'gojira'
  spec.version       = '1.0.0'
  spec.authors       = ['Alex Tylor']
  spec.email         = ['alex@tylor.co.uk']
  spec.summary       = 'A tool to populate my timesheets'
  spec.description   = 'A tool to fill time unbooked with bucket tasks that are weighted'
  spec.homepage      = 'https://github.com/terrortylor/gojira'
  spec.license       = 'MIT'

  spec.files = Dir.glob('{bin,lib}/**/*', File::FNM_DOTMATCH)
  spec.bindir        = 'bin'
  spec.executables   = %w[gojira]
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.17'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
