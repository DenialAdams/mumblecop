class Search < Plugin
  def initialize
    super
    @help_text = 'Search a video on youtube and play the first result - search [query]'
    @min_args = 1
    @commands = %w(ytsearch)
  end
 
  def go(source, args, bot)
    result = nil
    name = 'No title'
    error = 'No youtube-dl error'
    Open3.popen3('youtube-dl', '--prefer-insecure', '-i', '-f140', '-q', '--no-warnings', '-g', '--default-search', 'ytsearch:', args.join(' ')) do |_stdin, stdout, stderr|
      result = stdout.read.chomp
      error = stderr.read.chomp
    end
    bot.mpd.add(result)
    bot.mpd.play if bot.mpd.stopped?
    bot.say(self, source, 'Request successful. Loading...')
    Open3.popen3('youtube-dl', '--prefer-insecure', '-i', '-f140', '-q', '--no-warnings', '-e', '--default-search', 'ytsearch:', args.join(' ')) do |_stdin, stdout, _stderr|
      name = stdout.read.chomp
    end
    bot.say(self, source, 'Added "' + name + '".')
  rescue => e
    bot.say(self, source, 'Failed to play video. Try modifying your query.')
    bot.say(self, source, error)
    bot.say(self, source, e.message)
  end
end
