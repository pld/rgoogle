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
    results = []
    threads = []
    @params ||= "?v=1.0&key=#{@key}&q=#{CGI.escape(query)}&rsz=large&start="
    @date ||= Time.now

    1.upto(@pages) do |i|
      threads << Thread.new(i) do |start|
        results += get_results(start)
      end
    end

    threads.each { |thread| thread.join }
    @date = @params = nil

    results
  end

  def get_results(start)
    data = "#{@params}#{(start - 1) * NUM_RESULTS_PER_PAGE}"
    apicall = Net::HTTP.new(API_URI.host)
    response = apicall.get2(API_URI.path + data, { 'Referer' => @referer })
    response = JSON.parse(response.body)
    response["responseData"]["results"].map do |result|
      GoogleResult.new(
        result["titleNoFormatting"],
        result["content"],
        result["unescapedUrl"],
        @date
      )
    end
  end
end

