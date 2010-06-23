begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "roachclip"
    gemspec.summary = "MongoMapper plugin for Joint/Paperclip bliss"
    gemspec.description = "Let you upload images and have use paperclip's hotness to post process them"
    gemspec.email = "ryan@angilly.com"
    gemspec.homepage = "http://github.com/ryana/roachclip"
    gemspec.authors = ["Ryan Angilly"]

    gemspec.add_dependency 'joint', '0.3.2'
    gemspec.add_dependency 'paperclip', '2.3.3'
 
    gemspec.add_development_dependency 'shoulda', '2.11.0'
    gemspec.add_development_dependency 'mongo_mapper', '0.8.2'
  end
rescue LoadError
  puts "Jeweler not available. Install it with: gem install jeweler"
end
