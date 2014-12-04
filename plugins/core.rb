class Commands < Plugin
  def initialize
    super
    @help_text = "Prints out all available commands. If 'all' is given as an argument, prints out aliases too - commands (all)"
    @commands = ['commands']
  end

  def go(source, args, bot)
    if args[0] == 'all' || args[0] == 'aliases'
      bot.say(self, source, bot.commands.keys.sort.to_s)
    else
      commands = []
      bot.commands.values.uniq.each do |plugin|
        commands.push(plugin.commands[0])
      end
      bot.say(self, source, commands.sort.to_s)
    end
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
