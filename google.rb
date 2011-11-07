class Google
  NUM_RESULTS_PER_PAGE = 8
  PAGES = 6 # max 8
  GOOGLE_KEY = "[[REPLACE WITH YOUR GOOGLE KEY]]"

  def search(query)
    api_path = "http://ajax.googleapis.com/ajax/services/search/web"

    api = URI.parse(api_path)

    headers = {'Referer' => '[[REPLACE WITH REQUESTING URL]]'}
    results = []
    params = "?v=1.0&key=#{GOOGLE_KEY}&q=#{CGI.escape(query)}&rsz=large&start="
    threads = []
    date = Time.now

    1.upto(PAGES) do |start|
      threads << Thread.new(start) do |_start|
        data = "#{params}#{(_start - 1) * NUM_RESULTS_PER_PAGE}"
        apicall = Net::HTTP.new(api.host)
        response = apicall.get2(api.path + data, headers)
        response = JSON.parse(response.body)
        results += response["responseData"]["results"].map do |result|
          SearchEngine::Result.new({
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

