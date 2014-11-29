class Goto < Plugin
  def initialize
    super
    @help_text = 'Send mumblecop away to another channel. Poor mumblecop :('
    @min_args = 1
    @commands = ['goto']
  end

  def go(source, args, bot)
    bot.bot.join_channel(args[0])
  rescue
    bot.say(self, source, 'Failed to join that channel. Check permissions / if that channel exists.')
  end
end