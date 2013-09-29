require "sinatra"
require "net/http"
require "json"
require 'pry'

get '/' do
  erb :home
end

post '/stocks' do
  JSON.dump(get_stock_information(params[:name]))
end

helpers do
  CHANGE_INDEX = 1

  def get_stock_information(stock)
    {
      :probability => get_next_day_data(stock),
      :chart_data => @closing_percentage_changes
    }
  end

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


  def get_next_day_data(stock)
    all_matching_dates = get_all_matching_dates(stock)
    up_days_count = 0
    all_matching_dates.each do |current_day_data|
      current_day_index = @closing_percentage_changes.index(current_day_data)
      if (current_day_index + 1) < @closing_percentage_changes.length
        next_day_data = @closing_percentage_changes[current_day_index + 1]
        up_days_count += 1 if next_day_data[CHANGE_INDEX] > 0
      end

    end
     get_highest_probability(up_days_count, (all_matching_dates.length - 1))
  end

  def get_highest_probability(up_days, total_days)
    prob = ((up_days.to_f / total_days) * 100).round(2)
    if prob < 50
      [100 - prob, "down"]
    else
      [prob, "up"]
    end
  end

  def get_all_matching_dates(stock)
    percentages_array = closing_percentage_changes(stock)
    percentage_to_match = percentages_array.last[CHANGE_INDEX]
    percentage_range_to_match = ((percentage_to_match-0.05)..(percentage_to_match+0.05))
    percentages_array.select { |current_percentage| percentage_range_to_match.include? current_percentage[CHANGE_INDEX] }
  end

  def closing_percentage_changes(stock)
    data = years_of_data(stock, 3)
    changed_percentage = []
    data.reverse.each_cons(2) do |current, previous|
      changed_percentage << [
        Time.parse(current['date'] + " 12:00:00").getutc.to_i * 1000,
        daily_closing_percentage_change(current['Adj_Close'], previous['Adj_Close'])
      ]
    end
    @closing_percentage_changes = changed_percentage
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
