Gem::Specification.new do |spec|
  spec.name               = 'bel'
  spec.version            = '0.3.0'
  spec.summary            = %q{Process BEL with ruby.}
  spec.description        = %q{The BEL gem allows the reading, writing,
                               and processing of BEL (Biological Expression
                               Language) with a natural DSL.}.
                            gsub(%r{^\s+}, ' ').gsub(%r{\n}, '')
  spec.license            = 'Apache-2.0'
  spec.authors            = ['Anthony Bargnesi']
  spec.date               = %q{2014-01-13}
  spec.email              = %q{abargnesi@selventa.com}
  spec.files              = %w(INSTALL.md INSTALL_RUBY.md LICENSE README.md)
  spec.files              += Dir.glob("lib/**/*.rb")
  spec.files              += Dir.glob("ext/**/*.[ch]")
  spec.files              += Dir.glob("vendor/libbel/{AUTHORS,ChangeLog,COPYING,INSTALL,NEWS,README}")
  spec.files              += Dir.glob("vendor/libbel/{autogen.sh,configure.ac,libbel.pc.in,Makefile.am}")
  spec.files              += Dir.glob("vendor/libbel/{src}/*")
  spec.executables        = Dir.glob('bin/*').map(&File.method(:basename))
  spec.homepage           = 'https://github.com/OpenBEL/bel.rb'
  spec.require_paths      = ["lib"]
  spec.rdoc_options       = [
                              '--title', 'BEL Ruby Documentation',
                              '--main', 'README.md',
                              '--line-numbers',
                              '--exclude', 'lib/bel/script.rb',
                              'README.md',
                              'INSTALL.md',
                              'INSTALL_RUBY.md',
                              'LICENSE'
                            ]

  spec.required_ruby_version \
                          = '>= 1.9.2'

  spec.extensions         << 'ext/bel/extconf.rb'

  # runtime
  spec.add_dependency             'ffi',           '~> 1.9'

  # test rdf functionality
  spec.add_development_dependency 'uuid',          '~> 2.3'
  spec.add_development_dependency 'addressable',   '~> 2.3'
  spec.add_development_dependency 'rdf',           '~> 1.1'

  # development gems
  spec.add_development_dependency 'bundler',       '~> 1.7'
  spec.add_development_dependency 'rake',          '~> 10.4'
  spec.add_development_dependency 'rake-compiler', '~> 0.9'
  spec.add_development_dependency 'rspec',         '~> 3.2'
  spec.add_development_dependency 'yard',          '~> 0.8'
  spec.add_development_dependency 'rdoc',          '~> 4.2'
end
# vim: ts=2 sw=2:
# encoding: utf-8
