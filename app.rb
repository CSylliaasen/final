# Set up for the application and database. DO NOT CHANGE. #############################
require "sinatra"                                                                     #
require "sinatra/reloader" if development?                                            #
require "sequel"                                                                      #
require "logger"                                                                      #
require "twilio-ruby"                                                                 #
require "bcrypt"                                                                      #
require "geocoder"                                                                    #
connection_string = ENV['DATABASE_URL'] || "sqlite://#{Dir.pwd}/development.sqlite3"  #
DB ||= Sequel.connect(connection_string)                                              #
DB.loggers << Logger.new($stdout) unless DB.loggers.size > 0                          #
def view(template); erb template.to_sym; end                                          #
use Rack::Session::Cookie, key: 'rack.session', path: '/', secret: 'secret'           #
before { puts; puts "--------------- NEW REQUEST ---------------"; puts }             #
after { puts; }                                                                       #
#######################################################################################

trails_table = DB.from(:trails)
logs_table = DB.from(:logs)
users_table = DB.from(:users)

account_sid = ENV["TWILIO_ACCOUNT_SID"]
auth_token = ENV["TWILIO_AUTH_TOKEN"]
client = Twilio::REST::Client.new(account_sid, auth_token)

before do
    @current_user = users_table.where(user_id: session["user_id"]).to_a[0]
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
        client.messages.create(
        from: "+18183815131", 
        to: @current_user[:phone_number],
        body: "Just a heads up, someone just logged into your account! - Sent by TakeAHikeBot!"
        )
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
    @trails_table = trails_table
    @logs_table = logs_table
    view "user_detail"
end

get "/users/logs/new" do
    @trails_table = trails_table
    view "new_log"
end

post "/users/logs/create" do
    trail = trails_table.where(trail_name: params["trail_name"]).to_a[0]
    trail_id = trail[:trail_id]
    todays_date = DateTime.now
    logs_table.insert(user_id: session["user_id"], trail_id: trail_id, date: todays_date, duration: params["duration"], distance: params["distance"], notes: params["notes"])
    view "create_log"
end

get "/trails" do
    @trails_table = trails_table
    view "trails"
end

get "/trails/:trail_id/detail" do
    @trail = trails_table.where(trail_id: params["trail_id"]).to_a[0]
    results = Geocoder.search(@trail[:location])
    @lat_long = results.first.coordinates
    pp @lat_long
    view "trail_detail"
end

get "/trails/new" do
    view "new_trail"
end

post "/trails/create" do
    trails_table.insert(trail_name: params["trail_name"], location: params["location"], distance: params["trail_length"], difficulty: params["difficulty"], comments: params["comments"])
    view "create_trail"
end

get "/trails/leaderboard" do
    counter = 0
    leaderboard = [0]
    for user in users_table do
        puts number_of_logs = logs_table.where(user_id: user[:user_id]).count
        leaderboard[counter] = {name: user[:first_name], user_since: user[:creation_date][0,4],number_of_logs: number_of_logs }
        counter = counter + 1
    end
    @leaderboard = leaderboard.sort_by {|h| -h[:number_of_logs]}
    view "leaderboard"
end

get "/sign_off" do
    session["user_id"] = nil
    @current_user = nil
    view "sign_off"
end

get "/password_reset/new" do
    view "password_reset_new"
end

post "/password_reset/create" do
    user = users_table.where(email: params["email"]).to_a[0]
    if user != nil
        o = [('a'..'z'), ('A'..'Z')].map(&:to_a).flatten
        new_password = (0...12).map { o[rand(o.length)] }.join

        client.messages.create(
        from: "+18183815131", 
        to: user[:phone_number],
        body: "Your new password is: #{new_password} - Sent by TakeAHikeBot!"
        )
        users_table.where(user_id: user[:user_id]).update(:password => BCrypt::Password.create(new_password))
        view "password_reset_success"
    else
        view "password_reset_fail" 
    end
end