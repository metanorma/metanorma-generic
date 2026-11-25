Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}" }

gemspec

eval_gemfile("Gemfile.devel") rescue nil

# standoc α line: the Document model tree
gem "metanorma-standoc", git: "https://github.com/metanorma/metanorma-standoc.git",
    ref: "38133f98ab62f5bcbc93851b6b06792f49239c71"
gem "metanorma-core", git: "https://github.com/metanorma/metanorma-core.git",
    ref: "231ea6e236a6ccb199ff236df675b6a1edc0240a"
gem "metanorma-taste", git: "https://github.com/metanorma/metanorma-taste.git",
    ref: "d0c26613f78bf44fb10c07290b38b7e87aeaf544"
# Native presentation uses the shared LADL engine and typed adapter.
gem "metanorma-ladl", git: "https://github.com/metanorma/metanorma-ladl.git",
    ref: "361b29106e7dd7ffa753e0e35b097cd0cbf622f5"
gem "amath", "= 0.2.0"
gem "bigdecimal", "= 3.3.1"
# the released plugin line dropped the preprocessor names standoc main registers
gem "metanorma-plugin-lutaml", github: "metanorma/metanorma-plugin-lutaml", branch: "main"

gem "metanorma-document", git: "https://github.com/metanorma/metanorma-document.git",
    ref: "3911acbb4ce9d8497a94579610a42d663b8a78cd"

# canonical line: relaton 3 finals over the α engine line
gem "relaton", "~> 3.1.1"
gem "pubid", "~> 2.0"
gem "isodoc", "~> 3.7.9"
gem "isodoc-i18n", github: "metanorma/isodoc-i18n", branch: "main"
gem "canon", "~> 0.3"