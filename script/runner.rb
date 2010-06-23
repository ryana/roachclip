require 'mongo_mapper'
require File.join(File.dirname(__FILE__), '..', 'lib', 'roachclip')

MongoMapper.database = 'roachclip-runner'

class Sample
  include MongoMapper::Document
  plugin Roachclip

  roachclip :images, :styles => {:thumb => {:geometry => '50x50>'}, :large => {:geometry => '500x500>'}}
end
