require 'cgi'
require 'json'
require 'net/http'
require 'result'
require 'uri'

class RGoogle
  # API to Google's AJAX search API
  # 
  # Example:
  #   >> RGoogle.new('[API KEY]', '[Referer]').search('helioid')
  #   => [ #<Result:...>, ... ]
  #
  # Arguments:
  #   key: (String)
  #   referer: (String)

  NUM_RESULTS_PER_PAGE = 8
  PAGES = 6 # max 8
  API_PATH = "http://ajax.googleapis.com/ajax/services/search/web"
  API_URI = URI.parse(API_PATH)

  attr_accessor :key, :referer

  def initialize(key, referer)
    @key = key
    @referer = referer
  end

  def search(query)
    api = API_URI
    results = []
    params = "?v=1.0&key=#{@key}&q=#{CGI.escape(query)}&rsz=large&start="
    threads = []
    date = Time.now

    1.upto(PAGES) do |start|
      threads << Thread.new(start) do |_start|
        data = "#{params}#{(_start - 1) * NUM_RESULTS_PER_PAGE}"
        apicall = Net::HTTP.new(api.host)
        response = apicall.get2(api.path + data, { 'Referer' => @referer })
        response = JSON.parse(response.body)
        results += response["responseData"]["results"].map do |result|
          Result.new({
            :title => result["titleNoFormatting"],
            :abstract => result["content"],
            :url => result["unescapedUrl"],
            :date => date
          })
        end
      end
    end
    threads.each { |thread| thread.join }
    results
  end
end

