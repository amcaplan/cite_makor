require 'yaml'

describe CiteMakor::CalendaricRef do
  subject { described_class.replace_calendar_item_ref(text) }
  let(:calendars_response) { YAML.load_file(__dir__ + '/fixtures/calendars_response.yml') }

  before do
    allow(RestClient).to receive(:get).with(described_class::CALENDARS_API_URL).
      and_return(OpenStruct.new(body: calendars_response))
  end

  [
    ["Genesis 1:1", "Genesis 1:1"],
    ["daf yomi", "Eruvin 8a-b"],
    ["משנה יומית", "Mishnah Kelim 2:5-6"],
    ["929", "Zephaniah 2"],
  ].each do |ref, interpretation|
    context "interpreting \"#{ref}\"" do
      let(:text) { ref }

      it "replaces as expected" do
        expect(subject).to eq(interpretation)
      end
    end
  end
end
