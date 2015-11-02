# Plugin to auto-move inactive users to a specified channel
class AutoAfk < Plugin
  def initialize
    super
    @max_idle_seconds = 900
    @afk_channel_id = 6
    @idle_warning = true
    @idle_warning_time = 60
  end

  def setup(bot)
    bot.mumble.on_user_stats do |stats|
      break if bot.mumble.users.length == 0
      if stats.idlesecs > @max_idle_seconds
        bot.mumble.send_user_state(session: stats.session, channel_id: @afk_channel_id)
      elsif stats.idlesecs > @max_idle_seconds - @idle_warning_time && @idle_warning
        bot.mumble.say_to_user(stats.session, 'You will be automatically moved to AFK shortly.')
      end
    end
  end

  def update(bot)
    bot.mumble.users.each_value(&:stats)
  end
end
