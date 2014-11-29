class GetDateTime < Plugin
  def initialize
    super
    @help_text = 'Prints out the date and time'
    @commands = %w(date time)
  end

  def go(source, _args, bot)
    bot.say(self, source, Time.now.to_s)
  end
end