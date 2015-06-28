require 'json'

require 'sinatra'

class RestExample < Sinatra::Base

  set :raise_errors, true
  set :show_exceptions, :true
  set :logging, true

  def json(code, message)
    content_type :json
    halt code, message.to_json
  end

  before do
    if env['CONTENT_TYPE'] == 'application/json'
      body = request.body.read
      parsed_body = body.empty? ? {} : JSON.parse(body)
      STDOUT << "Params: #{parsed_body} #{headers} #{request.env}\n"
    else
      STDOUT << "Params: #{params} #{headers} #{request.env}\n"
    end
  end

  get '/plain/ok' do
    'OK'
  end

  post '/plain/ok' do
    'OK'
  end

  put '/plain/ok' do
    'OK'
  end

  get '/plain/ko' do
    [500, 'OK']
  end

  post '/plain/ko' do
    p params
    [500, 'OK']
  end

  put '/plain/ko' do
    p params
    [500, 'OK']
  end

  get '/json/ok' do
    json(200, {:code => 1})
  end

  post '/json/ok' do
    json(200, {:code => 1})
  end

  put '/json/ok' do
    json(200, {:code => 1})
  end

  get '/json/ko' do
    json(500, {:code => 1})
  end

  post '/json/ko' do
    json(500, {:code => 1})
  end

  put '/json/ko' do
    json(500, {:code => 1})
  end

end
