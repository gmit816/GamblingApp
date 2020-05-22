require 'sinatra'
require 'dm-core'
require 'dm-migrations'
#require 'data_mapper'

enable 'sessions'
DataMapper.setup(:default,ENV['DATABASE_URL']||"sqlite3://#{Dir.pwd}/gambling.db")

class Bet
    include DataMapper::Resource
    property :User_id, Serial
    property :User_name, String
    property :Password, String
    property :Win, Integer
    property :Lost, Integer
end
DataMapper.auto_upgrade!
DataMapper.finalize


configure do
    enable :sessions
end


configure :development do
	DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/gambling.db")
end

configure :development, :test do
	DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/gambling.db")
end

configure :production do
	#DataMapper.setup(:default, "postgres://#{Dir.pwd}/user.db")
	DataMapper.setup(:default, ENV['DATABASE_URL'] || 'postgres://localhost/gambling.db')
end

get '/' do
    erb :login
end

get '/login' do
    if session[:user]
        erb :home
    else
        erb :login
    end
end

post '/login' do
    id = Bet.first(:User_name =>params[:id])
    if id!=nil && id.Password== params[:password]
        session[:win]= 0
        session[:lost]= 0
        session[:password]= params[:password]
        session[:user]= params[:id]
        session[:total_win]= id.Win
        session[:total_lost]= id.Lost
        session[:id]=id.User_id
        erb :home
    else
        erb :login
    end
    #erb :home
end

post '/bet' do
    stake = params[:stake].to_i
    number = params[:number].to_i
    roll = rand(6) + 1
    if number == roll
      session[:win] += (stake*10)
      erb :home
    else
       session[:lost] += stake
        erb :home
    end
end

get '/logout' do
    session[:user] = nil
    session[:password] = nil
    id = Bet.get(session[:id])
    session[:total_win]+= session[:win]
    session[:total_lost]+= session[:lost]
    #id.lost+= session[:total_lost]
    id.update(:Win=>session[:total_win],:Lost=>session[:total_lost])
    erb :login
    #flash[:message] = "you have logged out..."
    redirect '/login'
end
