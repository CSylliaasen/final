# Set up for the application and database. DO NOT CHANGE. #############################
require "sinatra"                                                                     #
require "sinatra/reloader" if development?                                            #
require "sequel"                                                                      #
require "logger"                                                                      #
require "twilio-ruby"                                                                 #
require "bcrypt"                                                                      #
connection_string = ENV['DATABASE_URL'] || "sqlite://#{Dir.pwd}/development.sqlite3"  #
DB ||= Sequel.connect(connection_string)                                              #
DB.loggers << Logger.new($stdout) unless DB.loggers.size > 0                          #
def view(template); erb template.to_sym; end                                          #
use Rack::Session::Cookie, key: 'rack.session', path: '/', secret: 'secret'           #
before { puts; puts "--------------- NEW REQUEST ---------------"; puts }             #
after { puts; }                                                                       #
#######################################################################################

hikes_table = DB.from(:hikes)
logs_table = DB.from(:logs)
users_table = DB.from(:users)

before do
    @current_user = users_table.where(user_id: session["user_id"]).to_a[0]
end

get "/" do
    view "landing"
end

get "/logins/new" do
end

post "/logins/create" do
end

get "/users/new" do
end

get "/users/create" do
end

get "/users/:user_id" do
end

get "/users/:user_id/logs/new" do
end

get "/users/:user_id/logs/create" do
end

get "/trails" do
end

get "/trails/new" do
end

get "/users/create" do
end

get "/trails/leaderboard" do
end

get "/sign_off" do
    session["user_id"] = nil
    @current_user = nil
    view "sign_off"
end