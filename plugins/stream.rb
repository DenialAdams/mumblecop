# Allows users to stream an arbitrary stream url, for radio purposes
# It is input straight into mpd, so as far as I am aware there are no exploits here
# (there would need to be an exploit in mpd)
# A cautious user may wish to disable the plugin and use the radio plugin exclusively, which is a predefined stream list
class Stream < Plugin
  def initialize
    super
    @help_text = 'Start streaming from a source URL.'
    @min_args = 1
    @commands = %w(stream)
  end

  def go(source, _command, args, bot)
    bot.mpd.add(args[0])
    bot.mpd.play if bot.mpd.stopped?
    bot.say(self, source, "Given URL added to mpd queue.")
  rescue => e
    bot.say(self, source, 'Failed to play from URL.')
    bot.say(self, source, e.message)
    return 1
  end
end
