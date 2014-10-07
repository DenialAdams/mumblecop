# Base plugin class, when it is inherited it will register itself into @plugins
class Plugin
  attr_accessor :help_text, :enabled, :protected, :response, :min_args,
                :needs_sanitization, :commands

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
    @help_text ||= 'No help text included for this command'
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
    @help_text = "Have mumblecop say something in it's current channel - say [message]"
    super
  end

  def go(_source, args, bot)
    bot.say_to_channel(bot.current_channel, args.join(' '))
  end
end

class Whisper < Plugin
  def initialize
    @min_args = 2
    @commands = ['whisper']
    @help_text = 'Send a whisper from mumblecop to target user - whisper [user] [message]'
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

class Youtube < Plugin
  def initialize
    @needs_sanitization = true
    @commands = %w(youtube yt)
    @help_text = 'Play a youtube video - youtube [url]'
    @min_args = 1
    super
  end

  def go(source, args, bot)
    result = system('get_youtube', args[0])
    if result
      system('mpc play')
      bot.say(self, source, 'Request successful. Loading...')
    else
      bot.say(self, source, 'Failed to play video. Check given url.')
    end
  end
end

class Soundcloud < Plugin
  def initialize
    @needs_sanitization = true
    @commands = %w(soundcloud sc)
    @help_text = 'Play a soundcloud song - soundcloud [url]'
    @min_args = 1
    super
  end

  def go(source, args, bot)
    result = system('get_soundcloud', args[0])
    if result
      system('mpc play')
      bot.say(self, source, 'Request successful. Please wait a few moments for the source to begin streaming.')
    else
      bot.say(self, source, 'Failed to stream song. Check given url.')
    end
  end
end

class Fuck < Plugin
  def initialize
    @min_args = 1
    @help_text = 'Fuck a user anonymously - fuck [name]'
    @commands = ['fuck']
    super
  end

  def go(source, args, bot)
    if args[0] == CONFIG['username']
      bot.say(self, source, 'No, fuck you.')
    else
      bot.commands['whisper'].go(source, [args[0], 'Someone anonymously says fuck you.'], bot)
    end
  end
end

class Volume < Plugin
  def initialize
    @help_text = 'Change the volume, 0 - 100 - volume [[level]]. No params = check the volume'
    @commands = ['volume']
    @max_volume = 100
    super
  end

  def go(source, args, bot)
    if args[0]
      if args[0][0] == '-'
        new_volume = bot.bot.player.volume - args[0].to_i.abs
      elsif args[0][0] == '+'
        new_volume = bot.bot.player.volume + args[0].to_i.abs
      else
        new_volume = args[0].to_i
      end
      if new_volume > @max_volume
        bot.say(self, source, "Volume can not exeed #{@max_volume}. Set to #{@max_volume}.")
        bot.bot.player.volume = @max_volume
      else
        bot.bot.player.volume = new_volume
      end
    else
      bot.say(self, source, "Volume is currently #{bot.bot.player.volume}")
    end
  end
end

class Clear < Plugin
  def initialize
    @help_text = 'Stops anything playing, and clears the current playlist'
    @commands = ['clear']
    super
  end

  def go(_source, _args, _bot)
    system('mpc clear')
  end
end

class Next < Plugin
  def initialize
    @help_text = 'Advances to the next song in the queue.'
    @commands = %w(next advance)
    super
  end

  def go(_source, _args, _bot)
    system('mpc next')
  end
end

class GetDateTime < Plugin
  def initialize
    @help_text = 'Prints out the date and time'
    @commands = %w(date time)
    super
  end

  def go(source, _args, bot)
    bot.say(self, source, Time.now.to_s)
  end
end

class Commands < Plugin
  def initialize
    @help_text = 'Prints out all available commands'
    @commands = ['commands']
    super
  end

  def go(source, _args, bot)
    bot.say(self, source, bot.commands.keys.to_s)
  end
end

class Help < Plugin
  def initialize
    @help_text = 'Gives help about a specific command - help [command]'
    @commands = ['help']
    super
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

class Goto < Plugin
  def initialize
    @help_text = 'Send mumblecop away to another channel. Poor mumblecop :('
    @min_args = 1
    @commands = ['goto']
    super
  end

  def go(source, args, bot)
    bot.bot.join_channel(args[0])
  rescue
    bot.say(self, source, 'Failed to join that channel. Check permissions / if that channel exists.')
  end
end

class Seek < Plugin
  def initialize
    @help_text = 'Seek to x seconds in the currently playing media - seek [seconds]'
    @min_args = 1
    @commands = ['seek']
    super
  end

  def go(_source, args, _bot)
    system('mpc', 'seek', args[0])
  end
end
