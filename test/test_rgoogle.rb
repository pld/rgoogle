require 'test/unit'
require 'rgoogle'

$argv = ARGV.dup

class RGoogleTest < Test::Unit::TestCase
  # get an API key, https://code.google.com/apis/loader/signup.html
  TEST_KEY = '[YOUR GOOGLE AJAX SEARCH API KEY]'

  def test_set_key
    rg = RGoogle.new('valid-key', '')
    assert_equal 'valid-key', rg.key
  end

  def test_set_referer
    rg = RGoogle.new('', 'ref')
    assert_equal 'ref', rg.referer
  end

  # requires internet connectivity
  def test_get_search_response
    # use a valid google key to run test
    rg = RGoogle.new(TEST_KEY, 'example.com')
    assert_equal false, rg.search('helioid').empty?
  end
end

