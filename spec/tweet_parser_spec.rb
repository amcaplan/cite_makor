# require 'spec_helper'

describe CiteMakor::TweetParser do
  subject { described_class.new(text) }

  before do
    allow(CiteMakor::CustomLogger).to receive(:info)
  end

  [
    ["@CiteMakor please cite for me Genesis 1:1", "Genesis 1:1"],
    ["@CiteMakor please cite Genesis 1:1", "Genesis 1:1", details: "can leave out for me"],
    ["@CiteMakor Genesis 1:1", "", details: "need to say cite"],
    ["pleace cite @CiteMakor Genesis 1:1", "", details: "ignores cite before name"],
    ["@CiteMakor @amcaplan what are it's limits?", "", details: "ignoring a reply to someone else"],
    ["@CiteMakor @amcaplan @SefariaProject @CiteMakor cite for me בבא קמא ד ע\"א", "בבא קמא ד ע\"א", "replying to a reply to me"],
    ["I was gonna cosplay sailor moon, but...\n\n@CiteMakor cite me Deuteronomy 22:5", "Deuteronomy 22:5", "excluding preface"],
    ["@CiteMakor please cite for me Mishnah Sotah 3: 4 https://t.co/uk8YssrQDj", "Mishnah Sotah 3: 4", "excluding a twitter image/quote tweet/link"],

    # language tests
    ["@CiteMakor please cite for me Exodus 1:5 lang=he", "Exodus 1:5", lang: "he"],
    ["@CiteMakor please cite for me Leviticus 4:20 lang=en", "Leviticus 4:20", lang: "en"],
    ["@CiteMakor please cite for me Eruvin 12a lang=hebrew", "Eruvin 12a", lang: "he"],
    ["@CiteMakor please cite for me Mishnah Shabbat 12:1 lang=eng", "Mishnah Shabbat 12:1", lang: "en"]
  ].each do |tweet_text, ref, lang: nil, details: nil|
    context %Q{text = "#{tweet_text}"#{" (#{details})" if details}} do
      let(:text) { tweet_text}

      it "parses correctly" do
        expect(subject.ref).to eq(ref)
        expect(subject.lang).to eq(lang)
      end
    end
  end
end
