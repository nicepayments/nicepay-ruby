require 'sinatra'
require 'rest-client'
require 'securerandom'
require 'json'

require "openssl"

$clientId = 'S2_af4543a0be4d49a98122e01ec2059a56'
$secretKey = '9eb85607103646da9f9c02b128f2e5ee'

$key = $secretKey[0.. 31]
$iv = $secretKey[0.. 15]


get '/' do
    @orderId = SecureRandom.uuid
    erb :regist
end


post '/regist' do
    $plainText = "cardNo="+ params[:cardNo] + 
                 "&expYear=" + params[:expYear] + 
                 "&expMonth="+ params[:expMonth] + 
                 "&idNo=" + params[:idNo] + 
                 "&cardPw="+ params[:cardPw]

    response = RestClient::Request.new({
        url: 'https://sandbox-api.nicepay.co.kr/v1/subscribe/regist',
        headers: { content_type: 'application/json', accept: 'application/json'},
        method: :post,
        user: $clientId,
        password: $secretKey,
        payload: { 
            :encData => encrypt($plainText, $key, $iv),
            :orderId => SecureRandom.uuid,
            :encMode => 'A2'
        }.to_json
    }).execute do |response, request, result|
        case response.code
            when 200
                responseData = JSON.parse(response.body)
                @resultMsg = responseData["resultMsg"]  
                $bid = responseData["bid"] 
                billing($bid)
                expire($bid)
                puts response
                erb :result
            else
                fail "Invalid response #{response.to_str}"
        end
    end
end


def billing(bid)
    response = RestClient::Request.new({
        url: 'https://sandbox-api.nicepay.co.kr/v1/subscribe/' + bid + '/payments',
        headers: { content_type: 'application/json', accept: 'application/json'},
        method: :post,
        user: $clientId,
        password: $secretKey,
        payload: { 
            :orderId => SecureRandom.uuid,
            :amount => 1004,
            :goodsName => 'test',
            :cardQuota => 0,
            :useShopInterest => false
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


def expire(bid)
    response = RestClient::Request.new({
        url: 'https://sandbox-api.nicepay.co.kr/v1/subscribe/' + bid + '/expire',
        headers: { content_type: 'application/json', accept: 'application/json'},
        method: :post,
        user: $clientId,
        password: $secretKey,
        payload: { 
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


def encrypt(data, key, iv)
    aes = OpenSSL::Cipher.new('AES-256-CBC')
    aes.encrypt
    aes.key = key
    aes.iv = iv
    return (aes.update(data) + aes.final).unpack('H*').first
end