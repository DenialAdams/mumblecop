# This plugin is used to demonstrate plugin dependencies and calling another plugin
# The functionality could be done just by calling roll with +1 and as such is completely useless other than as an example
# But if you really want to use it more power to you
class RollPlusOne < Plugin
  def initialize
    super
    @min_args = 1
    @commands = %w(rollplusone)
    @help_text = 'Roll some dice and add one- 4d5 - see the dicebag ruby gem online for formatting.'
  end

  def go(source, args, bot)
    # We are directly using the result so we want to disable multithreading (this is also the default for plugin calls)
    result = bot.run_command("roll", args, [:plugin, self, source], multithread: false)
    # no fancy error handling, this is just a sample. result[0] gives error codes, see docs / bot.rb
    return if result[1] == nil
    bot.say(self, source, "#{result[1].total+1}")
  end

  def on_text_received(bot, source, text)
    # do nothing, we'll use result ourself in go
    # this squelchs the default text from the roll command
  end
end
