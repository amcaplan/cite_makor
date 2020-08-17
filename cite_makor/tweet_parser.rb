require __dir__ + '/logger'

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
          if relevant_text.any? { |word| word.start_with?('@') }
            CiteMakor::Logger.info "Mentioned other users after me, this is probably a reply, not answering. Tweet text:\n#{tweet_text}"
            []
          else
            text = relevant_text.reject { |i| i.match?(/\A(please|cite|for|me|https:\/\/t\.co\/\w+)\z/i) }
            text.reject! do |item|
              if matchdata = item.match(/\Alang(uage)?=(?<lang>he|en)/)
                @lang = matchdata[:lang]
              end
            end
            text
          end
        end
    end

    def relevant_text
      @relevant_text ||=
        begin
          last_mention_index = split_text.rindex { |word| word.match?(/\A@citemakor\z/i) } || -1
          split_text[(last_mention_index + 1)..-1]
        end
    end

    def split_text
      @split_text ||= tweet_text.strip.split(/\s+/)
    end
  end
end
