require 'sinatra'
require 'rest-client'
require 'securerandom'
require 'json'

$clientId = 'S2_af4543a0be4d49a98122e01ec2059a56'
$secretKey = '9eb85607103646da9f9c02b128f2e5ee'

get '/' do
    @orderId = SecureRandom.uuid
    @clientId = $clientId
    erb :index
end

get '/cancel' do
    erb :cancel
end

post '/serverAuth' do
    response = RestClient::Request.new({
        url: 'https://sandbox-api.nicepay.co.kr/v1/payments/' + params[:tid],
        headers: { content_type: 'application/json', accept: 'application/json'},
        method: :post,
        user: $clientId,
        password: $secretKey,
        payload: { :amount => params[:amount]}.to_json
    }).execute do |response, request, result|
        case response.code
            when 200
                responseData = JSON.parse(response.body)
                @resultMsg = responseData["resultMsg"]      
                puts response
                erb :result
            else
                fail "Invalid response #{response.to_str}"
        end
    end
end

post '/cancel' do
    response = RestClient::Request.new({
        url: 'https://sandbox-api.nicepay.co.kr/v1/payments/'+ params[:tid] + '/cancel',
        headers: { content_type: 'application/json', accept: 'application/json'},
        method: :post,
        user: $clientId,
        password: $secretKey,
        payload: { 
            :amount => params[:amount],
            :reason => 'test',
            :orderId => SecureRandom.uuid
        }.to_json
    }).execute do |response, request, result|
        case response.code
            when 200
                responseData = JSON.parse(response.body)
                @resultMsg = responseData["resultMsg"]      
                puts response
                erb :result
            else
                fail "Invalid response #{response.to_str}"
        end
    end
end

post '/hook' do
    puts request.body.read
    status 200
    body 'ok'    
end