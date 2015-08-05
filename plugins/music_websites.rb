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
    format = '-f140'
    format = '-f141' if @quality == :high || args.include?('high')
    format = '-f140' if args.include?('normal')
    Open3.popen3('youtube-dl', '--prefer-insecure', '-i', format, '-q', '--no-warnings', '-ge', "#{args[0]}") do |_stdin, stdout, stderr|
      result = stdout.read.chomp
      error = stderr.read.chomp
    end
    # Split the result into the title (0) and the stream (1)
    result = result.split("\n")
    bot.mpd.add(result[1])
    # MPD doesn't like quotes in the track for send_command so as a hack we change them to single quotes
    result[0].tr!('"', "'")
    bot.mpd.send_command('addtagid', bot.mpd.queue.last.id, 'title', result[0])
    bot.mpd.send_command('addtagid', bot.mpd.queue.last.id, 'albumartist', bot.get_username_from_source(source))
    bot.mpd.play if bot.mpd.stopped?
    bot.say(self, source, "Request successful. Loading #{result[0]}...")
    bot.mpd.seek(args[1].to_i) if args[1] && args[1].to_i != 0
  rescue => e
    bot.say(self, source, 'Failed to load video. Check given url, quality, and seek parameter.')
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
    bot.mpd.send_command('addtagid', bot.mpd.queue.last.id, 'albumartist', bot.get_username_from_source(source))
    bot.mpd.play if bot.mpd.stopped?
    bot.say(self, source, 'Request successful. Loading...')
    bot.mpd.seek(args[1].to_i) if args[1]
  rescue => e
    bot.say(self, source, 'Failed to stream song. Check given url and seek parameter (if given.)')
    bot.say(self, source, error)
    bot.say(self, source, e.message)
  end
end
