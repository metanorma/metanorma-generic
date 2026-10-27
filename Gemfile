Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}" }

gemspec

eval_gemfile("Gemfile.devel") rescue nil

# standoc α line: the Document model tree
gem "metanorma-standoc", "~> 3.5.1.pre.alpha"
# the released plugin line dropped the preprocessor names standoc main registers
gem "metanorma-plugin-lutaml", github: "metanorma/metanorma-plugin-lutaml", branch: "main"

gem "metanorma-document", "~> 0.5.2.pre.alpha" # SvgmapElement and the base component tree

# canonical line: relaton 3 finals over the α engine line
gem "relaton", "~> 3.0"
gem "relaton-render", "~> 3.0"
gem "pubid", "~> 2.0"
gem "isodoc", "~> 3.7.4.pre.alpha"
gem "isodoc-i18n", github: "metanorma/isodoc-i18n", branch: "main"
gem "canon", "0.3.87"
