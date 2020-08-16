module CiteMakor
  class TweetParser
    def initialize(tweet_text)
      @tweet_text = tweet_text
    end

    def ref
      tweet_text.strip.split(' ').reject { |i| i.match?(/(@citemakor|please|cite|for|me)/i) }.join(' ')
    end

    private
    attr_reader :tweet_text
  end
end
