$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "each_batched/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "each_batched"
  s.version     = EachBatched::VERSION
  s.authors     = ["David Burry"]
  s.email       = ["dburry@falcon"]
  s.homepage    = "http://github.com/dburry/each_batched"
  s.summary     = "More convenient batching than Rails' ActiveRecord::Batches#find_in_batches"
  s.description = "ActiveRecord::Batches#find_in_batches has some gotchas.  This library provides alternate algorithms that may better suit you, in certain circumstances.  Specifically: you can order your results other than by primary key, and you can limit your batches to just a certain range of results not only all records."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", ">= 3.0"
  s.add_dependency "valium"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "shoulda"
  s.add_development_dependency "simplecov"
  # s.add_development_dependency "bundler" # included in rails
  # s.add_development_dependency "rdoc" # included in rails
  # s.add_development_dependency "rake" # included in rails
end
