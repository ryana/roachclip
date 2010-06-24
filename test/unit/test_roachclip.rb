require File.join(File.dirname(__FILE__), 'test_helper')

class RoachclipTest < Test::Unit::TestCase

  class Doc
    include MongoMapper::Document
  end

  MongoMapper.database = 'roachclip-test'

  def teardown
    Doc.all.each &:destroy
  end

  should "overwrite Paperclip.log" do
    assert_nothing_raised {Paperclip.log "some info"}
  end

  context "A document with Roachclip and Joint plugged in" do
    setup do
      Doc.plugin Roachclip
    end

    should "plugin Roachclip" do
      assert Doc.respond_to?(:roachclip)
    end

    should "get roaches" do
      assert Doc.respond_to?(:roaches)
      assert Doc.respond_to?(:roaches=)
    end

    should "add images to roaches" do
      opts = {:styles => {:thumb => {:geometry => '50x50'}}}
      Doc.roachclip :image, opts

      assert Doc.roaches.find {|x| x ==  {:name => :image, :options => opts} }
    end

    context "with large and thumb" do
      setup do
        @opts = {:styles => {:thumb => {:geometry => '50x50'}, :large => {:geometry => '500x500>'}}}
        Doc.roachclip :image, @opts
      end

      context "with validations" do
        setup do
          Doc.validates_roachclip :image
        end

        context "on a new instance" do
          setup do
            @doc = Doc.new
          end

          should "validate presence of images" do
            assert !@doc.valid?
            assert @doc.errors.on(:image)
          
            @doc.image = File.open(test_file_path)
            assert @doc.valid?
          end
        end
      end

      should "add attachments for each option style" do
        d = Doc.new

        assert d.respond_to?(:image_thumb)
        assert d.respond_to?(:image_thumb=)
        assert d.respond_to?(:image_large)
        assert d.respond_to?(:image_large=)
      end

      context "with a saved document w/ image" do
        setup do
          @doc = Doc.new
          @doc.image = File.open(test_file_path)

          assert @doc.save
        end

        should "still save documents w/ images" do
          d = Doc.find @doc.id

          assert_equal fname, d.image_name
          assert_equal File.size(test_file_path), d.image_size
        end

        should "destroy thumbs when image set to nil" do
          @doc.image = nil
          @doc.save!

          d = Doc.find(@doc.id)
          # until joint supports clearing IDs
          assert_raises(Mongo::GridFileNotFound) { d.image_thumb.read }
          assert_raises(Mongo::GridFileNotFound) { d.image_large.read }
        end

        should "have thumb and large" do
          assert @doc.image_thumb.size > 0
          assert @doc.image_large.size > 0

          assert_equal 'fonz_thumb.jpg', @doc.image_thumb_name
          assert_equal 'fonz_large.jpg', @doc.image_large_name
        end
      end
    end
  end

  def fname
    'fonz.jpg'
  end

  def test_file_path
    @test_file_path = File.join(File.dirname(__FILE__), '..', 'data', fname)
  end
end
