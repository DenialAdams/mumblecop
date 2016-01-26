# Plugin that allows the bot to be moved to another channel
class Goto < Plugin
  def initialize
    super
    @help_text = "Send #{CONFIG['username']} to another channel."
    @min_args = 1
    @commands = %w(goto gt)
  end

  def go(source, _command, args, bot)
    bot.mumble.join_channel(args.join(' '))
  rescue
    bot.say(self, source, 'Failed to join that channel. Check permissions / if that channel exists.')
  end
end
