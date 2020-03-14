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
    pp @current_user
end

get "/" do
    view "landing"
end

get "/logins/new" do
    view "new_login"
end

post "/logins/create" do
    user = users_table.where(email: params["email"]).to_a[0]
    if user && BCrypt::Password::new(user[:password]) == params["password"]
        session["user_id"] = user[:user_id]
        @current_user = user
        view "create_login"
    else
        view "create_login_failed"
    end
end

get "/users/new" do
    view "new_user"
end

post "/users/create" do
    hashed_password = BCrypt::Password.create(params["password"])
    todays_date = DateTime.now
    users_table.insert(first_name: params["first_name"], last_name: params["last_name"], email: params["email"], phone_number: params["phone_number"], creation_date: todays_date, password: hashed_password)
    view "create_user"
end

get "/users/user_detail" do
    view "user_detail"
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