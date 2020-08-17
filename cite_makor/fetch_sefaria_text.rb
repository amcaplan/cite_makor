require 'json'
require 'rest-client'
require __dir__ + '/utils'
require __dir__ + '/errors'

module CiteMakor
  class FetchSefariaText
    def initialize(ref, lang)
      @ref = ref
      @lang = lang
    end

    def sefaria_text
      if response_text
        sefaria_text = Array(response_text).join(" ")
        text = CiteMakor::Utils.word_wrap(sefaria_text.gsub(/<.*?>/,''))
        if text.lines.size > 78
          raise CiteMakor::Errors::TextTooLong.new("You requested a #{sefaria_text.length}-character text (#{formatted_ref}), please ask for something shorter!")
        end
        closer = "- #{formatted_ref}".rjust(CiteMakor::Utils.line_length(text.each_line.first) * 1.2)
        text << "\n" << closer
      else
        raise CiteMakor::Errors::InvalidRef.new("Sorry, I couldn't figure out what \"#{ref}\" refers to, please try rephrasing.")
      end
    end

    def formatted_ref
      response_content[lang == 'he' ? 'heRef' : 'ref']
    end

    def html_url
      sefaria_response.request.url.sub('/api/texts','')
    end

    private
    attr_reader :ref

    def status
      sefaria_response.code
    end

    def response_text
      keys = lang == 'he' ? %w(he text) : %w(text he)
      response_content.values_at(*keys).find { |text| text && !text.empty? }
    end

    def response_content
      JSON.parse(sefaria_response.body)
    end

    def lang
      @lang ||= ref.match?(/[א-ת]/) ? 'he' : 'en'
    end

    def sefaria_response
      @sefaria_response ||=
        begin
          url = "https://www.sefaria.org/api/texts/#{ERB::Util.url_encode(ref)}?context=0"
          RestClient.get(url)
        end
    end
  end
end
