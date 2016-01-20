# Causes the bot to follow the user who calls the command.
class Follow < Plugin
  def initialize
    super
    @help_text = "Order #{CONFIG['name']} to follow you around. 'Unfollow' causes the bot to stop."
    @following_user = nil
    @commands = %w(follow unfollow)
  end

  def go(source, command, _args, bot)
    if command == 'unfollow'
      if @following_user
        bot.say(self, source, 'No longer following any user.')
      else
        bot.say(self, source, 'Not currently following anyone.')
      end
      @following_user = nil
    else
      if source[0] == :channel
        @following_user = source[2]
      elsif source[0] == :user
        @following_user = source[1]
      end
      return unless @following_user
      bot.say(self, source, "Now following #{bot.get_username_from_source(source)}.")
    end
  end

  def update(bot)
    if bot.mumble.users[@following_user].nil?
      @following_user = nil
      return
    end
    following_channel = bot.mumble.users[@following_user].channel_id.to_i
    bot.mumble.join_channel(following_channel) if following_channel != bot.current_channel
  end
end
