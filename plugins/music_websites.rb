require 'open3'
class Youtube < Plugin
  def initialize
    super
    @needs_sanitization = true
    @commands = %w(youtube yt)
    @help_text = 'Play a youtube video - youtube [url] (starting time in seconds)'
    @min_args = 1
    @quality = :normal
  end

  def go(source, args, bot)
    result = nil
    error = 'No youtube-dl error'
    if @quality == :high || args.include?('high')
      format = '-f141'
    end
    if args.include?('normal')
      format = '-f140'
    end
    Open3.popen3('youtube-dl', '--prefer-insecure', '-i', format, '-q', '--no-warnings', '-g', "#{args[0]}") do |_stdin, stdout, stderr|
      result = stdout.read.chomp
      error = stderr.read.chomp
    end
    bot.mpd.add(result)
    bot.mpd.play if bot.mpd.stopped?
    bot.say(self, source, 'Request successful. Loading...')
    bot.mpd.seek(args[1].to_i) if args[1] && args[1].to_i != 0
   rescue => e
     bot.say(self, source, 'Failed to play video. Check given url, quality, and seek parameter.')
     bot.say(self, source, error)
     bot.say(self, source, e.message)
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
    result = nil
    error = 'No youtube-dl error'
    Open3.popen3('youtube-dl', '--prefer-insecure', '-i', '-g', '-q', '--no-warnings', "#{args[0]}", '-f', 'mp3') do |_stdin, stdout, stderr|
      result = stdout.read.chomp
      error = stderr.read.chomp
    end
    bot.mpd.add(result)
    bot.mpd.play if bot.mpd.stopped?
    bot.say(self, source, 'Request successful. Loading...')
    bot.mpd.seek(args[1].to_i) if args[1]
  rescue => e
    bot.say(self, source, 'Failed to stream song. Check given url and seek parameter (if given.)')
    bot.say(self, source, error)
    bot.say(self, source, e.message)
  end
end
