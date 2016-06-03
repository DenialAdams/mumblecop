# Blame plugin to see who added last track
# This relies on album artist being submitter
# That is kind of hack but a standard I am using
# (really no good alternative, i investigated stickers but to no avail)
class Submitter < Plugin
  def initialize
    super
    @help_text = 'Find out who submitted the song that is currently playing.'
    @min_args = 0
    @commands = %w(submitter blame)
  end

  def go(source, _command, _args, bot)
    current_song = bot.mpd.current_song
    if current_song.nil?
      bot.say(self, source, 'No song currently playing.')
    elsif current_song.albumartist.nil?
      bot.say(self, source, 'No submitter information available.')
    else
      bot.say(self, source, current_song.albumartist)
    end
  end
end
