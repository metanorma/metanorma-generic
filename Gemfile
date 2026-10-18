Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}" }

gemspec

eval_gemfile("Gemfile.devel") rescue nil

# standoc main: the Document model tree (released 3.5.0 predates it)
gem "metanorma-standoc", github: "metanorma/metanorma-standoc", branch: "main"
# the released plugin line dropped the preprocessor names standoc main registers
gem "metanorma-plugin-lutaml", github: "metanorma/metanorma-plugin-lutaml", branch: "main"

# metanorma-document main: SvgmapElement and the base component tree
gem "metanorma-document", github: "metanorma/metanorma-document", branch: "main"

# canonical line: relaton 3 prerelease monogem + git-main render/core
# (released isodoc 3.7.3 lacks the moxml-aware BibdataConfig wrapper;
# released relaton alpha.5 crashes the bibdata Liquid drop round-trip)
gem "relaton", "= 3.0.0.pre.alpha.14"
gem "relaton-render", "= 3.0.0.pre.alpha.43"
gem "relaton-bib", "2.2.0.pre.alpha.1"
gem "pubid", github: "pubid/pubid", branch: "main"
gem "leptris", "1.9.352.0"
gem "isodoc", github: "metanorma/isodoc", branch: "main"
gem "isodoc-i18n", github: "metanorma/isodoc-i18n", branch: "main"
gem "canon", "0.3.87"
