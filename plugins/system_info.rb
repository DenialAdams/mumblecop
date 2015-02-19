# Command that returns the result of system command uname and ruby version
class SystemInfo < Plugin
  def initialize
    super
    @commands = %w(system server)
    @help_text = 'Info about the server and ruby version'
  end

  def go(source, _args, bot)
    bot.say(self, source, `uname -a`) unless Gem.win_platform?
    bot.say(self, source, RUBY_DESCRIPTION)
    return unless CONFIG['use-mpd']
    bot.say(self, source, `mpd --version`.lines[0])
    begin
      bot.say(self, source, 'Youtube-dl: ' + `youtube-dl --version`)
    rescue
    end
  end
end
