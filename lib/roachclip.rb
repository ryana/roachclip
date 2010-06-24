require 'set'
require 'tempfile'
require 'paperclip'
require 'joint'

module Paperclip
  class << self
    def log *args
    end
  end
end

module Roachclip
  autoload :Version, 'roachclip/version'

  class InvalidAttachment < StandardError; end

  def self.configure(model)
    model.plugin Joint
    model.class_inheritable_accessor :roaches
    model.roaches = Set.new
  end

  module ClassMethods
    def roachclip name, options
      self.attachment name

      raise InvalidAttachment unless attachment_names.include?(name)

      self.roaches << {:name => name, :options => options}
 
      options[:styles].each { |k,v| self.attachment "#{name}_#{k}"}

      before_save :process_roaches
      before_save :destroy_nil_roaches
    end

    def validates_roachclip name, options = {}
      default_options = {:present => true}
      options = default_options.merge(options)

      if options[:present]
        validates_each name, :logic => lambda { errors.add(name, 'is required') unless send("#{name}_id").present? }
      end
    end
  end

  module InstanceMethods
    def process_roaches
      roaches.each do |img|
        name = img[:name]
        styles = img[:options][:styles]

        return unless assigned_attachments[name]

        src = Tempfile.new ["roachclip", name.to_s].join('.')
        src.write assigned_attachments[name].read
        src.close
        
        assigned_attachments[name].rewind

        styles.keys.each do |style_key|
          thumbnail = Paperclip::Thumbnail.new src, styles[style_key]
          tmp_file_name = thumbnail.make
          stored_file_name = send("#{name}_name").gsub(/\.(\w*)\Z/) { "_#{style_key}.#{$1}" }
          send "#{name}_#{style_key}=", tmp_file_name
          send "#{name}_#{style_key}_name=", stored_file_name
        end
      end
    end

    def destroy_nil_roaches
      roaches.each do |img|
        name = img[:name]
        styles = img[:options][:styles]

        return unless @nil_attachments && @nil_attachments.include?(name)

        styles.keys.each do |style_key|
          send "#{name}_#{style_key}=", nil
        end
      end
    end
  end
end
