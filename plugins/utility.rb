class GetDateTime < Plugin
  def initialize
    super
    @help_text = 'Prints out the date and time'
    @commands = %w(date time)
  end

  def go(source, _args, bot)
    bot.say(self, source, Time.now.to_s)
  end
end

class GetUserHash < Plugin
  def initialize
    super
    @help_text = "Gets the hash of a user's certificate, for verifying identity - hash [username]"
    @commands = %w(hash)
    @min_args = 1
  end

  def go(source, args, bot)
    bot.say(self, source, bot.mumble.find_user(args[0]).hash)
  end
end
