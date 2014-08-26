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
    rescue
      bot.say(self, source, 'User not found.')
    end
  end
end

class Roll < Plugin
  def initialize
    @min_args = 1
    @commands = ['roll']
    @help_text = "Roll an x sided die with the format - roll <sides>"
    super
  end

  def go(source, args, bot)
    sides = args[0]
    #bot.say(source, args[0]
  end
end
