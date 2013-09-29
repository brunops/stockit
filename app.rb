require "sinatra"

get '/' do
  erb :home
end

post '/stocks' do
  "Stockton!"
end
