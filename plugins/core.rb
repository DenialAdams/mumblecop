class Commands < Plugin
  def initialize
    super
    @help_text = "Prints out all available commands. If 'all' is given as an argument, prints out aliases too - commands (all)"
    @commands = %w(commands)
  end

  def go(source, _command, args, bot)
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
    @commands = %w(help)
  end

  def go(source, _command, args, bot)
    if args[0]
      if bot.commands[args[0]].nil?
        bot.say(self, source, 'Command you requested help on is not found.')
      elsif bot.commands[args[0]].help_text.empty?
        bot.say(self, source, 'Command has no set help text.')
      else
        bot.say(self, source, bot.commands[args[0]].help_text)
      end
    else
      bot.say(self, source, @help_text + ". For a list of commands, try 'commands'")
    end
  end
end

class Refresh < Plugin
  def initialize
    super
    @help_text = 'Reload certain information from mumblecop config files.'
    @commands = %w(reload)
  end

  def go(source, _command, _args, bot)
    bot.mumble.player.volume = CONFIG['initial-volume']
    begin
      bot.mumble.set_comment(CONFIG['comment_text']) if CONFIG['comment'] == :text
    rescue
      puts 'ERROR: Failed to set comment. Does your version of mumble-ruby support this feature?'
    end
    bot.reload_permissions
    bot.say(self, source, 'Successfully reloaded.')
  end
end
