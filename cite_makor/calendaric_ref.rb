require 'json'
require 'rest-client'

module CiteMakor
  class CalendaricRef
    CALENDARS_API_URL = "https://www.sefaria.org/api/calendars"

    calendar_response = RestClient.get(CALENDARS_API_URL)
    calendar_items = JSON.parse(calendar_response).fetch("calendar_items")
    CALENDAR_ITEMS = calendar_items
    item_titles = CALENDAR_ITEMS.flat_map { |item| item["title"].values }
    CALENDAR_ITEMS_REGEX = /(#{item_titles.join('|')})/i
    CALENDAR_ITEMS_MAP = CALENDAR_ITEMS.each_with_object({}) do |item, hash|
      item["title"].values.each do |title|
        hash[title] = item["ref"]
      end
    end

    def self.replace_calendar_item_ref(string)
      string.sub(CALENDAR_ITEMS_REGEX) do |match|
        CALENDAR_ITEMS_MAP.find { |k, v| k.downcase == match.downcase }.last
      end
    end
  end
end
