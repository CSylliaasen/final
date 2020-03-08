# Set up for the application and database. DO NOT CHANGE. #############################
require "sequel"                                                                      #
connection_string = ENV['DATABASE_URL'] || "sqlite://#{Dir.pwd}/development.sqlite3"  #
DB = Sequel.connect(connection_string)                                                #
#######################################################################################

# Database schema - this should reflect your domain model
DB.create_table! :hikes do
  primary_key :hike_id
  String :hike_name
  String :location
  String :distance
  String :difficulty
  String :comments, text: true
end
DB.create_table! :logs do
  primary_key :log_id
  foreign_key :user_id
  foreign_key :hike_id
  String :date
  String :duration
  String :distance
  String :notes, text: true
end
DB.create_table! :users do
  primary_key :user_id
  String :first_name
  String :last_name
  String :email
  String :phone_number
  String :creation_date
  String :password
end

# Insert initial (seed) data
hikes_table = DB.from(:hikes)
logs_table = DB.from(:logs)
users_table = DB.from(:users)

hikes_table.insert( hike_name: "Kettle Moraine", 
                    location: "Kettle Moraine, WI",
                    distance: "10 miles",
                    difficulty: "Easy",
                    comments: "Beautiful scenic hike with lots of lakes and trees!")

hikes_table.insert( hike_name: "Pictured Rocks", 
                    location: "Munising, MI",
                    distance: "15 miles",
                    difficulty: "Hard",
                    comments: "Wonderful walk along the lake. Not a loop so be sure to have a return strategy.")

hikes_table.insert( hike_name: "Starved Rock", 
                    location: "Oglesby, IL",
                    distance: "5 miles",
                    difficulty: "Moderate",
                    comments: "Great day trip for Chigago-nians!")

hikes_table.insert( hike_name: "Isle Royale", 
                    location: "Lake Superior",
                    distance: "20 miles",
                    difficulty: "Hard",
                    comments: "Incredible trip but is difficult to get to. Must take a sea-place or a very long boat ride from Michigan or Minnesota.")

hikes_table.insert( hike_name: "Mark Twain National Forest", 
                    location: "Kaolin Township, MO",
                    distance: "10 miles",
                    difficulty: "Easy",
                    comments: "Beautiful park. But be careful, gets very buggy in the summer months")