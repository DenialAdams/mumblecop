# Command that returns the result of system command uptime
class Uptime < Plugin
  def initialize
    super
    @commands = %w(uptime ut)
    @help_text = 'Stats about the server uptime'
    @enabled = false if Gem.win_platform?
  end

  def go(source, _args, bot)
    bot.say(self, source, `uptime`)
  end
end
