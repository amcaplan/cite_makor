require __dir__ + '/custom_logger'

module CiteMakor
  class TweetParser
    def initialize(tweet_text)
      @tweet_text = tweet_text
    end

    def ref
      ref_text.join(' ')
    end

    def lang
      ref_text
      @lang
    end

    private
    attr_reader :tweet_text

    def ref_text
      @ref_text ||=
        begin
          text = relevant_text.reject { |i| i.match?(/\A(please|cite|for|me|https:\/\/t\.co\/\w+|@\w+)\z/i) }
          text.reject! do |item|
            if matchdata = item.match(/\Alang(uage)?=(?<lang>he|en)/)
              @lang = matchdata[:lang]
            end
          end
          text
        end
    end

    def relevant_text
      @relevant_text ||=
        begin
          match = tweet_text.strip.gsub(/\s+/, ' ').match(/@CiteMakor(\splease)?\scite(\sfor)?(\sme)?\s(?<ref_text>[^\n]+)/)
          (match&.[](:ref_text) || "").split(' ')
        end
    end
  end
end
