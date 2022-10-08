require 'sinatra'
require 'json'
require 'sqlite3'

require_relative './my_user_model.rb'

enable :sessions

set :bind, '0.0.0.0'
set :port, 8000
set('views', './views')

get '/users' do
    users = User.all

    users.collect do |row|
        row.to_hash.slice(:id, :firstname, :lastname, :age, :email).to_json
    end
end

# Sign In. Add a session containing the user_id in order to be logged in
# curl -X POST localhost:8080/sign_in -d email=ace@email.com -d password=SUPERSECRET
post '/sign_in' do
    erb :sign_in

    params['email']
    params['password']
    users = User.all
    user = users.filter { |user| user.email == params['email'] && user.password == params['password'] }.first
    
    if user
        session[:user_id] = user.id
        redirect "/"
        "Signed In"
    else
        "Not authorized"
    end
end

post '/users' do
    User.create(params)
    "OK"
end

#Receive a new password and return an updated user hash
put '/users' do
    if session[:user_id]
        users = User.all
        user = users.filter { |user| user.id == session[:user_id] }.first
        User.update(user.id, :password, 'new_password')
    else
        "NOT AUTHORIZED"
    end

    updated_users = User.all
    p updated_user = updated_users.filter { |user| user.id == session[:user_id] }.first
    print updated_user.to_hash.to_json
    return updated_user.to_hash.to_json
end

get '/sign_out' do
    erb :sign_out
end

# Sign Out the current user
delete '/sign_out' do
    session.clear
    p "Sign out successful!"
    redirect '/sign_out'
end

# It will sign_out the current user and it will destroy the current user.
delete '/users' do
    users = User.all
    user = users.filter { |user| user.id == session[:user_id] }.first
    p "Singing out and Deleting #{user}."
    User.destroy(session[:user_id])
    session.clear
end

get '/sign_in' do
    @name = params["name"]
    erb :sign_in
end

get '/' do
    @users = User.all

    erb :index
end
