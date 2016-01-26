# Command that returns the result of system command uptime
class Uptime < Plugin
  def initialize
    super
    @commands = %w(uptime ut)
    @help_text = 'Stats about the server uptime - note that this is for the server as a whole, not mumblecop exclusively'
    @enabled = false if Gem.win_platform?
  end

  def go(source, _command, _args, bot)
    bot.say(self, source, `uptime`)
  end
end
