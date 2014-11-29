class Youtube < Plugin
  def initialize
    super
    @needs_sanitization = true
    @commands = %w(youtube yt)
    @help_text = 'Play a youtube video - youtube [url] (starting time in seconds)'
    @min_args = 1
  end

  def go(source, args, bot)
    begin
      result = `youtube-dl --prefer-insecure -i -f140 -g "#{args[0]}"`
      result.chomp!
      puts [result].to_s
      bot.mpd.add(result)
      bot.mpd.play if bot.mpd.stopped?
      bot.say(self, source, 'Request successful. Loading...')
      bot.mpd.seek(args[1].to_i) if args[1]
    rescue
      bot.say(self, source, 'Failed to play video. Check given url and seek paramater (if given.)')
    end
  end
end

class Soundcloud < Plugin
  def initialize
    super
    @needs_sanitization = true
    @commands = %w(soundcloud sc)
    @help_text = 'Play a soundcloud song - soundcloud [url] (starting time in seconds)'
    @min_args = 1
  end

  def go(source, args, bot)
    result = system('get_soundcloud', args[0])
    if result
      bot.mpd.play if bot.mpd.stopped?
      bot.say(self, source, 'Request successful. Please wait a few moments for the source to begin streaming.')
      bot.mpd.seek(args[1].to_i) if args[1]
    else
      bot.say(self, source, 'Failed to stream song. Check given url.')
    end
  end
end