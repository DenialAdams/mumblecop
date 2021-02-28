# Search youtube and add the first result
class Search < Plugin
  def initialize
    super
    @help_text = 'Search a video on youtube and play the first result - search [query]'
    @min_args = 1
    @commands = %w(ytsearch yts)
  end

  def go(source, _command, args, bot)
    result = nil
    error = 'No youtube-dl error'
    Open3.popen3('youtube-dl', '-i', '-f140', '-q', '--no-warnings', '--no-cache-dir', '-ge', '--default-search', 'ytsearch:', args.join(' ')) do |_stdin, stdout, stderr|
      result = stdout.read.chomp
      error = stderr.read.chomp
    end
    result = result.split("\n")
    bot.mpd.add(result[1])
    bot.mpd.send_command('addtagid', bot.mpd.queue.last.id, 'title', result[0])
    bot.mpd.send_command('addtagid', bot.mpd.queue.last.id, 'albumartist', bot.get_username_from_source(source))
    bot.mpd.play if bot.mpd.stopped?
    bot.say(self, source, 'Added "' + result[0] + '".')
  rescue => e
    bot.say(self, source, 'Failed to play video. Try modifying your query.')
    bot.say(self, source, error)
    bot.say(self, source, e.message)
    return 1
  end
end
