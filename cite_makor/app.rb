require 'json'
require 'twitter'
require 'aws-sdk-dynamodb'

require __dir__ + '/calendaric_ref'
require __dir__ + '/cloudinary_image'
require __dir__ + '/errors'
require __dir__ + '/fetch_sefaria_text'
require __dir__ + '/tweet_parser'

def process_mention(mention, client:)
  begin
    parser = CiteMakor::TweetParser.new(mention.text)
    ref = CiteMakor::CalendaricRef.replace_calendar_item_ref(parser.ref)
    fetcher = CiteMakor::FetchSefariaText.new(ref, parser.lang)
    CiteMakor::CloudinaryImage.new(fetcher.sefaria_text).with_image_files do |files|
      client.update_with_media(<<~TWEET_TEXT, files, in_reply_to_status: mention)
        @#{mention.user.screen_name} Here's your citation!
        #{fetcher.formatted_ref}
        #{fetcher.html_url}
      TWEET_TEXT
    end
  rescue CiteMakor::Errors::Error => e
    client.update("@#{mention.user.screen_name} #{e.message}", in_reply_to_status: mention)
  end
end

def dynamodb_client
  @dynamodb_client ||= Aws::DynamoDB::Client.new(region: 'us-east-1')
end

def get_latest_tweet
  dynamodb_client.get_item(table_name: 'tweets', key: { significance: 'latest' })
end

def set_latest_tweet(id)
  dynamodb_client.put_item(table_name: 'tweets', item: { significance: 'latest', id: id })
end

def run
  client = Twitter::REST::Client.new do |config|
    config.consumer_key        = ENV["TWITTER_CONSUMER_KEY"]
    config.consumer_secret     = ENV["TWITTER_CONSUMER_SECRET"]
    config.access_token        = ENV["TWITTER_ACCESS_TOKEN"]
    config.access_token_secret = ENV["TWITTER_ACCESS_TOKEN_SECRET"]
  end

  since_id = get_latest_tweet.to_h.dig(:item, "id")
  since_id = since_id.to_i if since_id # leave nil if it's nil, otherwise convert number to int
  tweets = client.mentions_timeline({ count: 200, since_id: since_id, tweet_mode: :extended }.compact)
  return if tweets.empty?

  queue = Thread::SizedQueue.new(50)

  threads = 10.times.map {
    Thread.new do
      loop do
        mention = queue.pop
        break if mention == :STOP
        begin
          process_mention(mention, client: client)
        rescue => e
          p e
        end
      end
    end
  }

  # No retries!!!
  set_latest_tweet(tweets.first.id)
  tweets.each do |mention|
    queue << mention
  end
  threads.size.times { queue << :STOP }
  threads.each(&:join)
end

def lambda_handler(event:, context:)
  # Sample pure Lambda function

  # Parameters
  # ----------
  # event: Hash, required
  #     API Gateway Lambda Proxy Input Format
  #     Event doc: https://docs.aws.amazon.com/apigateway/latest/developerguide/set-up-lambda-proxy-integrations.html#api-gateway-simple-proxy-for-lambda-input-format

  # context: object, required
  #     Lambda Context runtime methods and attributes
  #     Context doc: https://docs.aws.amazon.com/lambda/latest/dg/ruby-context.html

  # Returns
  # ------
  # API Gateway Lambda Proxy Output Format: dict
  #     'statusCode' and 'body' are required
  #     # api-gateway-simple-proxy-for-lambda-output-format
  #     Return doc: https://docs.aws.amazon.com/apigateway/latest/developerguide/set-up-lambda-proxy-integrations.html

  # begin
  #   response = HTTParty.get('http://checkip.amazonaws.com/')
  # rescue HTTParty::Error => error
  #   puts error.inspect
  #   raise error
  # end

  run

  {
    statusCode: 200,
    body: {
      message: "Completed!",
      # location: response.body
    }.to_json
  }
end
