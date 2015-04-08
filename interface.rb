require 'net/http'
require 'json'

class Interface
    attr_accessor :uri, :req, :res, :data
    def initialize name, password
        @server = "http://localhost:1337"
        @name = name
        @password = password
        update_token
    end

    def login
        @uri = URI("#{@server}/api/auth/login/?email=#{@name}&password=#{@password}")
        @req = Net::HTTP::Get.new @uri
        @res = Net::HTTP.start(@uri.host,@uri.port) do |http|
            http.request @req
        end
        if @res.code == "200"
            return JSON.parse(@res.body)['token']
        end
    end

    def update_token
        @token = login
    end

    def request path, query
        update_token
        @uri = URI("#{@server}#{path}#{query}")
        @req = Net::HTTP::Get.new @uri
        @req['access-token'] = @token
        @res = Net::HTTP.start(@uri.host,@uri.port) do |http|
            http.request @req
        end
        @data = JSON.parse(@res.body)
        if @res.code == "200" # or @res.message == "OK"
            return @data
        end
    end

    def index
        path = "/api/instrument/index"
        query = ""
        request path, query
    end

    def historical instrument, granularity, start, endtime
        path = "/api/instrument/historical"
        query = "?name=#{instrument}&granularity=#{granularity}&start=#{start}&end=#{endtime}"
        request path, query
    end

    def rawdata name, count, granularity
        path = "/api/instrument/rawdata"
        query = "?name=#{name}&count=#{count}&granularity=#{granularity}"
        request path, query
    end
end
