class Say < Plugin
  def initialize
    super
    @min_args = 1
    @commands = %w(say)
    @help_text = "Have mumblecop say something in it's current channel - say [message]"
  end

  def go(_source, args, bot)
    bot.say_to_current_channel(args.join(' '))
  end
end

class Whisper < Plugin
  def initialize
    super
    @min_args = 2
    @commands = ['whisper']
    @help_text = 'Send a whisper from mumblecop to target user - whisper [user] [message]'
  end

  def go(source, args, bot)
    user = args[0]
    args.delete_at(0)
    text = args.join(' ')
    if bot.say_to_user(user, text) != 1
      bot.say(self, source, 'Message sent.')
    else
      bot.say(self, source, 'User not found.')
    end
  end
end
