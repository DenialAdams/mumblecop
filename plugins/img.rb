require 'base64'
require 'net/http'

# TODO: investigate https issues, resizing
class UrlToImg < Plugin
  def initialize
    super
    @help_text = 'Displays the image associated to an url - img [url]'
    @commands = %w(img image urltoimg urltoimage)
    @min_args = 1
    @needs_sanitization = true
    # Generally, this should match the setting in your murmur config. -1 = no max.
    @max_size = 128
  end

  def go(source, args, bot)
    url = args[0]
    url = 'http://' + url unless url.start_with?('http://', 'https://')
    uri = URI(url)
    http = Net::HTTP.new(uri.host, uri.port)
    begin
      response = http.request(
        Net::HTTP::Get.new(uri.request_uri, 'User-Agent' => 'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:31.0) Gecko/20100101 Firefox/31.0'))
      image = Base64.encode64(response.body)
      msg = '<a href="' + url + '"><img src="data:image/jpeg;base64,' + image + '"/></a>'
      size = msg.bytesize / 1024
      if @max_size > 0 && size <= @max_size
        bot.say(self, source, msg)
      else
        bot.say(self, source, 'The image is too big to be posted.')
      end
    rescue
      bot.say(self, source, 'Failed to load the image. Check the url.')
    end
  end
end
