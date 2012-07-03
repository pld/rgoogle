require 'cgi'
require 'json'
require 'net/http'
require 'uri'


GoogleResult = Struct.new :title, :abstract, :url, :date


class RGoogle
  # API to Google's AJAX search API
  # 
  # Example:
  #   >> RGoogle.new('[API KEY]', '[Referer]').search('helioid')
  #   => [ #<GoogleResult:...>, ... ]
  #
  # Arguments:
  #   key: (String)
  #   referer: (String)
  #   pages: (Integer+ <= 8)

  NUM_RESULTS_PER_PAGE = 8
  API_PATH = "http://ajax.googleapis.com/ajax/services/search/web"
  API_URI = URI.parse(API_PATH)

  attr_accessor :key, :referer, :pages

  def initialize(key, referer='', pages=6)
    @key = key
    @referer = referer
    @pages = pages < 8 ? pages : 8
  end

  def search(query)
    api = API_URI
    results = []
    params = "?v=1.0&key=#{@key}&q=#{CGI.escape(query)}&rsz=large&start="
    threads = []
    date = Time.now

    1.upto(@pages) do |start|
      threads << Thread.new(start) do |_start|
        data = "#{params}#{(_start - 1) * NUM_RESULTS_PER_PAGE}"
        apicall = Net::HTTP.new(api.host)
        response = apicall.get2(api.path + data, { 'Referer' => @referer })
        response = JSON.parse(response.body)
        results += response["responseData"]["results"].map do |result|
          GoogleResult.new(
            result["titleNoFormatting"],
            result["content"],
            result["unescapedUrl"],
            date
          )
        end
      end
    end
    threads.each { |thread| thread.join }
    results
  end
end

