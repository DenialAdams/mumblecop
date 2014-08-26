class Plugin
  attr_accessor :help_text, :enabled, :protected, :response, :min_args, :requires_sanitization, :commands
  
  def self.plugins
    @plugins ||= []
  end
  
  def self.inherited(klass)
    @plugins ||= []
    @plugins << klass
  end

  def initialize
    @requires_sanitization ||= false
    @min_args ||= 0
    @enabled ||= true
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
    @help_text = "Have robocop say something in it's current channel - say <message>"
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
    @help_text = "Send a whisper from robocop to target user - whisper <user> <message>"
    super
  end

  def go(source, args, bot)
    user = args[0]
    args.delete_at(0)
    text = args.join
    begin
      bot.say_to_user(user, text)
      bot.say(self, source, 'Message sent.')
    rescue
      bot.say(self, source, 'User not found.')
    end
  end
end

class Roll < Plugin
  def initialize
    @min_args = 1
    @commands = ['roll']
    @help_text = "Roll an x sided die - roll <sides>"
    super
  end

  def go(source, args, bot)
    sides = args[0].to_i
    bot.say(self, source, rand(1..sides).to_s)
  end
end

class Youtube < Plugin
  def initialize
    @require_sanitization = true
    @commands = ['youtube']
    @help_text = "Play a youtube video - youtube <url>"
    @min_args = 1
    super
  end

  def go(source, args, bot)
    system('mpc clear')
    result = system('get_youtube', term)
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
    @help_text = "Fuck a user anonymously - fuck <name>"
    @commands = ['fuck']
    super
  end

  def go(source, args, bot)
    bot.say_to_user(args[0], 'Someone says fuck you.')
  end
end
