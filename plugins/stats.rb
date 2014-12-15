class Uptime < Plugin
  def initialize
    super
    @commands = %w(uptime ut)
    @help_text = 'Stats about the server uptime'
  end

  def go(source, _args, bot)
    bot.say(self, source, `uptime`)
  end
end
