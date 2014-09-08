class Plugin
  attr_accessor :help_text, :enabled, :protected, :response, :min_args, :needs_sanitization, :commands
  
  def self.plugins
    @plugins ||= []
  end
  
  def self.inherited(klass)
    @plugins ||= []
    @plugins << klass
  end

  def initialize
    @needs_sanitization ||= false
    @min_args ||= 0
    @enabled = true if @enabled.nil?
    @protected ||= false # does nothing yet
    @help_text ||= "No help text included for this command"
    @response ||= :auto
  end

  def go
    # stub for now
  end
end

class Say < Plugin
  def initialize
    @min_args = 1
    @commands = ['say']
    @help_text = "Have robocop say something in it's current channel - say [message]"
    super
  end

  def go(source, args, bot)
    bot.say_to_channel(bot.current_channel, args.join(" "))
  end 
end

class Whisper < Plugin
  def initialize
    @min_args = 2
    @commands = ['whisper']
    @help_text = "Send a whisper from robocop to target user - whisper [user] [message]"
    super
  end

  def go(source, args, bot)
    user = args[0]
    args.delete_at(0)
    text = args.join
    if bot.say_to_user(user, text) != 1
      bot.say(self, source, 'Message sent.')
    else
      bot.say(self, source, 'User not found.')
    end
  end
end

class Roll < Plugin
  def initialize
    @min_args = 1
    @commands = ['roll']
    @help_text = "Roll an x sided die - roll [sides]"
    super
  end

  def go(source, args, bot)
    sides = args[0].to_i
    bot.say(self, source, rand(1..sides).to_s)
  end
end

class Youtube < Plugin
  def initialize
    @needs_sanitization = true
    @commands = ['youtube']
    @help_text = "Play a youtube video - youtube [url]"
    @min_args = 1
    super
  end

  def go(source, args, bot)
    system('mpc clear')
    result = system('get_youtube', args[0])
    if result
      system('mpc play')
      bot.say(self, source, 'Request successful. Please wait a few moments for the source to download.')
    else
      bot.say(self, source, 'Failed to play video. Check given url.')
    end
  end
end

class Fuck < Plugin
  def initialize
    @min_args = 1
    @help_text = "Fuck a user anonymously - fuck [name]"
    @commands = ['fuck']
    super
  end

  def go(source, args, bot)
    if args[0] == $USERNAME
      bot.say(self, source, "No, fuck you.")
    else
      bot.commands['whisper'].go(source, [args[0], "Someone anonymously says fuck you."], bot)
    end
  end
end

class Volume < Plugin
  def initialize
    @help_text = "Change the volume, 0 - 100 - volume [[level]]. No params = check the volume"
    @commands = ['volume']
    super
  end

  def go(source, args, bot)
    if args[0]
      if args[0][0] == "-"
        bot.bot.player.volume = bot.bot.player.volume - args[0].to_i.abs
      elsif args[0][0] == "+"
        bot.bot.player.volume = bot.bot.player.volume + args[0].to_i.abs
      else
        bot.bot.player.volume = args[0].to_i
      end
    else
      bot.say(self, source, "Volume is currently #{bot.bot.player.volume}")
    end
  end
end

class Stop < Plugin
  def initialize
    @help_text = "Stops anything playing"
    @commands = ['stop']
    super
  end

  def go(source, args, bot)
    system('mpc clear')
  end
end

class GetDateTime < Plugin
  def initialize
    @help_text = "Prints out the date and time"
    @commands = ['date', 'time']
    super
  end

  def go(source, args, bot)
    bot.say(self, source, Time.now.to_s)
  end
end

class Commands < Plugin
  def initialize
    @help_text = "Prints out all available commands"
    @commands = ['commands']
    super
  end

  def go(source, args, bot)
    bot.say(self, source, bot.commands.keys.to_s)
  end
end

class Help < Plugin
  def initialize
    @help_text = "Gives help about a specific command - help [command]"
    @commands = ['help']
    @min_args = 1
    super
  end

  def go(source, args, bot)
    if bot.commands[args[0]].nil?
      bot.say(self, source, "Sorry, command you requested help on is not found.")
    elsif bot.commands[args[0]].help_text.empty?
      bot.say(self, source, "Sorry, command has no set help text.")
    else
      bot.say(self, source, bot.commands[args[0]].help_text)
    end
  end
end

class Goto < Plugin
  def initialize
    @help_text = "Send robocop away to another channel. Poor robocop :("
    @min_args = 1
    @commands = ['goto']
    super
  end

  def go(source, args, bot)
    begin
      bot.bot.join_channel(args[0])
    rescue
      bot.say(self, source, "Failed to join that channel. Check permissions / if that channel exists.")
    end
  end
end

class Seek < Plugin
  def initialize
    @help_text = "Seek to x seconds in the currently playing media - seek [seconds]"
    @min_args = 1
    @commands = ['seek']
    super
  end

  def go(source, args, bot)
    system("mpc seek #{args[0]}")
  end
end
