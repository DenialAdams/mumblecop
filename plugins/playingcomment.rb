# Keeps mumble comment up to date with song metadata info
class PlayingComment < Plugin
  def initialize
    super
  end

  def setup(bot)
    return unless CONFIG['comment'] == :now_playing
    bot.mpd.on :song do |song|
      bot.mumble.set_comment(get_comment(song))
    end
    bot.mpd.on :state do |state|
      if state == :pause
        bot.mumble.set_comment('Playback paused')
      else
        bot.mumble.set_comment(get_comment(bot.mpd.current_song))
      end
    end
  end

  def get_comment(song)
    if song.nil?
      CONFIG['comment_text']
    elsif song.artist && song.title
      "Now playing: #{song.title} - #{song.artist}"
    elsif song.title
      "Now playing: #{song.title}"
    else
      'Now playing unknown'
    end
  end
end
