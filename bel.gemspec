Gem::Specification.new do |spec|
  spec.name               = 'bel'
  spec.version            = '0.1.0'
  spec.summary            = %q{Process BEL with ruby.}
  spec.description        = %q{The BEL gem allows the reading, writing,
                               and processing of BEL (Biological Expression
                               Language) with a natural DSL.}.
                            gsub(%r{^\s+}, ' ').gsub(%r{\n}, '')
  spec.authors            = ['Anthony Bargnesi']
  spec.date               = %q{2013-07-18}
  spec.email              = %q{abargnesi@selventa.com}
  spec.files              = Dir.glob('lib/**/*.rb')
  spec.homepage           = 'https://github.com/OpenBEL/bel.rb'
  spec.require_paths      = ["lib"]

  spec.add_development_dependency 'rake',    '~> 10.1.0'
  spec.add_development_dependency 'rspec',   '~> 2.14.0'
  spec.add_development_dependency 'yard',    '~> 0.8.7.0'
  spec.add_development_dependency 'rdoc',    '~> 4.0.0'
  spec.add_development_dependency 'bundler', '~> 1.3.0'
end
