
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'tokenplay/version'

Gem::Specification.new do |spec|
  spec.name          = 'tokenplay'
  spec.version       = TokenPlay::VERSION
  spec.authors       = ['Vince']
  spec.email         = ['vincem@tokenplay.com']

  spec.summary       = 'TokenPlay Ruby SDK.'
  spec.description   = 'TokenPlay Ruby SDK.'
  spec.homepage      = 'https://ewallet.tokenplay.com/'
  spec.license       = 'Apachev2'

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'faraday', '~> 0.13.1'

  spec.add_development_dependency 'bundler', '~> 1.15'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop', '~> 0.50.0'
  spec.add_development_dependency 'rubocop-rspec', '~> 1.12'
  spec.add_development_dependency 'webmock', '~> 2.1'
  spec.add_development_dependency 'vcr', '~> 3.0'
  spec.add_development_dependency 'pry-byebug', '~> 3.4.2'
end
