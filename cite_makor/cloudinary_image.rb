require 'cloudinary'
require 'open-uri'

module CiteMakor
  class CloudinaryImage
    def initialize(text)
      @text = text
    end

    def with_image_files(texts=text_portions, files=[], &block)
      return block.call(files) if texts.empty?
      first, *rest = texts
      with_image_file(first) do |file|
        with_image_files(rest, files + [file], &block)
      end
    end

    def with_image_file(text_portion)
      with_public_id(text_portion) do |public_id|
        URI.open(image_url(public_id)) do |file|
          Tempfile.open('text.webp') do |tf|
            tf.pwrite(file.read, 0)
            yield tf
          end
        end
      end
    end

    private
    attr_reader :text

    def text_portions
      text.each_line.each_slice(20).map { |slice| slice.join("\n") }
    end

    def with_public_id(text_portion)
      image = Cloudinary::Uploader.text(
        text_portion,
        font_family: 'Times New Roman',
        font_size: 42,
        background: 'white'
      )
      yield image["public_id"]
    rescue CloudinaryException => e
      p e
      raise CiteMakor::Errors::CloudinaryError.new("Something went wrong, please try again later.")
    ensure
      Cloudinary::Uploader.destroy(image["public_id"], type: 'text') if image
    end

    def image_url(public_id)
      Cloudinary::Utils.cloudinary_url(
        public_id,
        type: 'text',
        border: '5px_solid_white',
        background: 'white',
        fetch_format: 'webp',
        quality: 'auto'
      )
    end
  end
end
