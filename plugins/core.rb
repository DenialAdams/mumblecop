class Commands < Plugin
  def initialize
    super
    @help_text = 'Prints out all available commands'
    @commands = ['commands']
  end

  def go(source, _args, bot)
    bot.say(self, source, bot.commands.keys.to_s)
  end
end

class Help < Plugin
  def initialize
    super
    @help_text = 'Gives help about a specific command - help [command]'
    @commands = ['help']
  end

  def go(source, args, bot)
    if args[0]
      if bot.commands[args[0]].nil?
        bot.say(self, source, 'Sorry, command you requested help on is not found.')
      elsif bot.commands[args[0]].help_text.empty?
        bot.say(self, source, 'Sorry, command has no set help text.')
      else
        bot.say(self, source, bot.commands[args[0]].help_text)
      end
    else
      bot.say(self, source, @help_text + ". For a list of commands, try 'commands'")
    end
  end
end
