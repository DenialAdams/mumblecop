# Get (server) date and time
class GetDateTime < Plugin
  def initialize
    super
    @help_text = 'Prints out the date and time, as it is on the server'
    @commands = %w(date time)
  end

  def go(source, _command, _args, bot)
    bot.say(self, source, Time.now.to_s)
  end
end

# Get users hash for trusted permissions, etc
# (see wiki)
class GetUserHash < Plugin
  def initialize
    super
    @help_text = "Gets the hash of a user's certificate, for verifying identity - hash [username]"
    @commands = %w(hash)
    @min_args = 1
  end

  def go(source, _command, args, bot)
    hash = bot.mumble.find_user(args[0]).hash
    if !hash.is_a?(String)
      bot.say(self, source, 'Invalid username.')
    else
      bot.say(self, source, hash)
    end
  end
end
