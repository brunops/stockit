require "sinatra"
require "net/http"

get '/' do
  erb :home
end

post '/stocks' do
  get_historical_data_for(params[:name], Time.now.year)
end 

helpers do 
  def get_historical_data_for(ticker, til)
    uri =URI("http://query.yahooapis.com/v1/public/yql")
    query = get_query(ticker, til)
    env = "store://datatables.org/alltableswithkeys"
    res = Net::HTTP.post_form(uri, {"q" => query, 'env' => env, 'format'=> 'json'})
    res.body
  end

  def get_query(ticker, til)
    month = Time.now.month
    day = Time.now.day
 
    start_date = Time.new((til-1),month,day).strftime("%Y-%m-%d")
    end_date = Time.new(til,month,day).strftime("%Y-%m-%d")
    "select * from yahoo.finance.historicaldata where symbol = '#{ticker}' and startDate = '#{start_date}' and endDate = '#{end_date}'"
  end

  def closing_percentage_changes
  return [
          {"date" => "2009-02-02", "change" => 2.25},
          {"date" => "2009-02-03", "change" => 0.15},
          {"date" => "2009-02-04", "change" => 1.25},
          {"date" => "2009-02-05", "change" => 2.25},
          {"date" => "2009-02-06", "change" => -2.25},
          {"date" => "2009-02-06", "change" => -1.25},
          {"date" => "2009-02-06", "change" => -2.25},
          {"date" => "2009-02-06", "change" => 2.25},
          {"date" => "2009-02-06", "change" => 2.25},
          {"date" => "2009-02-05", "change" => 2.25},
          {"date" => "2009-02-06", "change" => -2.25},
          {"date" => "2009-02-06", "change" => -1.25},
          {"date" => "2009-02-06", "change" => -2.25},
          {"date" => "2009-02-06", "change" => 2.25},
          {"date" => "2009-02-06", "change" => 2.25}
         ]    
  end

  def matching_dates
    percentage_to_match = 2.25
    percentage_range_to_match = ((percentage_to_match-.05)..(percentage_to_match+0.5))
    percentages_array = closing_percentage_changes
    percentages_array.select { |current_percentage| percentage_range_to_match.include? current_percentage["change"] }
  end

end


