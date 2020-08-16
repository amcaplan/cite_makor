module CiteMakor
  class TweetParser
    def initialize(tweet_text)
      @tweet_text = tweet_text
    end

    def ref
      split_text.join(' ')
    end

    def lang
      split_text
      @lang
    end

    private
    attr_reader :tweet_text

    def split_text
      @split_text ||=
        begin
          text = tweet_text.strip.split(' ').reject { |i| i.match?(/\A(@citemakor|please|cite|for|me)\z/i) }
          text.reject! do |item|
            if matchdata = item.match(/\Alang(uage)?=(?<lang>he|en)/)
              @lang = matchdata[:lang]
            end
          end
          text
        end
    end
  end
end
