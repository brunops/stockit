require "sinatra"
require "net/http"
require "json"

get '/' do
  erb :home
end

post '/stocks' do
  JSON.dump(closing_percentage_changes(params[:name]))
end

helpers do
  def get_historical_data_for(ticker, til)
    uri = URI("http://query.yahooapis.com/v1/public/yql")
    query = get_query(ticker, til)
    env = "store://datatables.org/alltableswithkeys"
    res = Net::HTTP.post_form(uri, {"q" => query, 'env' => env, 'format'=> 'json'})
    parsed_result = JSON.parse(res.body)

    parsed_result['query']['results']['quote'] if parsed_result['query']['results']
  end

  def get_query(ticker, til)
    month = Time.now.month
    day = Time.now.day
    start_date = Time.new((til-1),month,day).strftime("%Y-%m-%d")
    end_date = Time.new(til,month,day).strftime("%Y-%m-%d")
    "select * from yahoo.finance.historicaldata where symbol = '#{ticker}' and startDate = '#{start_date}' and endDate = '#{end_date}'"
  end

  def matching_dates(stock)
    percentages_array = closing_percentage_changes(stock)
    percentage_to_match = percentages_array.first['change']
    percentage_range_to_match = ((percentage_to_match-0.05)..(percentage_to_match+0.5))
    percentages_array.select { |current_percentage| percentage_range_to_match.include? current_percentage["change"] }
  end

  def closing_percentage_changes(stock)
    data = years_of_data(stock, 3)
    changed_percentage = []
    data.reverse.each_cons(2) do |current, previous|
      changed_percentage << {
        'date' => current['date'],
        'change' => daily_closing_percentage_change(current['Adj_Close'], previous['Adj_Close'])
      }
    end
    changed_percentage.reverse
  end

  def daily_closing_percentage_change(today_value, yesterday_value)
    ((yesterday_value.to_f * 100) / today_value.to_f) - 100
  end

  def years_of_data(stock, years)
    current_year = Time.now.year
    i = 0
    data = []
    while (i < years) do
      current_year_data = get_historical_data_for(stock, current_year - i)
      break if current_year_data.nil?

      data += current_year_data
      i = i + 1
    end

    data
  end
end
