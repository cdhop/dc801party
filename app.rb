require File.expand_path('config/config')

class App < Sinatra::Base
  configure :development, :production, :staging do
    enable :logging
  end

  set :root, File.dirname(__FILE__)
  set :logging, true

  get '/' do
    @title = "Party Fulfillment"
    erb :index
  end

  get '/scan' do
    @title = "Scan QRCode"
    erb :scan
  end

  get '/order/:code' do
    @title = "Order Details"
    begin
      raise 'Invalid QR Code' unless /[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}/ =~ params[:code] 
      order = get_order(params[:code])
      raise "#{order['message']}" if order['message'] != 'Success'
      @order_details = order['data']
      erb :order
    rescue Exception => e
      @error_message = e.message
      erb :error
    end
  end

  get '/order/:code/complete' do
    @title = "Order Complete"
    begin
      raise 'Invalid QR Code' unless /[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}/ =~ params[:code] 
      results = complete_order(params[:code])
      raise "#{results['message']}" if results['message'] != 'Success'
      erb :complete
    rescue Exception => e
      @error_message = e.message
      erb :error
    end
  end

  not_found do
    @title = "Not Found"
    erb :not_found
  end

  error do
    @title = "Error"
    erb :error
  end

  def get_order(guid)
    c = Curl::Easy.new('https://www.dc801.org/party2017/Retrieve/order/' + guid)
    #c.http_auth_types = :basic
    #c.username = 'foo'
    #c.password = 'bar'
    c.perform
    response_js = JSON.parse(c.body_str)
  end

  def complete_order(guid)
    payload = '{"guid": "' + guid + '"}'    
    c = Curl::Easy.http_post('https://www.dc801.org/party2017/complete/order', payload) do |curl|
      curl.headers['Accept'] = 'application/json'
      curl.headers['Content-Type'] = 'application/json'
    end
    #c.http_auth_types = :basic
    #c.username = 'foo'
    #c.password = 'bar'
    c.perform
    response_js = JSON.parse(c.body_str)
  end

end
