module CiteMakor
  module Errors
    class Error < StandardError; end
    class TextTooLong < Error; end
    class InvalidRef < Error; end
    class CloudinaryError < Error; end
    class SefariaError < Error; end
  end
end
