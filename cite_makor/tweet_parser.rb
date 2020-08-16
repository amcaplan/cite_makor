module CiteMakor
  class TweetParser
    def initialize(tweet_text)
      @tweet_text = tweet_text
    end

    def ref
      tweet_text.strip.split(' ').reject { |i| i.match?(/\A(@citemakor|please|cite|for|me)\z/i) }.join(' ')
    end

    private
    attr_reader :tweet_text
  end
end