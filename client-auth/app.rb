require 'sinatra'
require 'rest-client'
require 'securerandom'
require 'json'

$clientId = 'S1_6eaa0db1afdc41f3becb770878d67d25'
$secretKey = 'e80d068e400649a6ada66777fa350d40'

get '/' do
    @orderId = SecureRandom.uuid
    @clientId = $clientId
    erb :index
end

get '/cancel' do
    erb :cancel
end

post '/clientAuth' do
    @resultMsg = request["resultMsg"]      
    puts request.body.read
    erb :result
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