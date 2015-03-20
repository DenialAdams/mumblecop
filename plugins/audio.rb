class Seek < Plugin
  def initialize
    super
    @help_text = 'Seek to x seconds in the currently playing media - seek [seconds]'
    @min_args = 1
    @commands = %w(seek)
  end

  def go(_source, args, bot)
    bot.mpd.seek(args[0]) if bot.mpd.playing?
  end
end

class WhatsPlaying < Plugin
  def initialize
    super
    @help_text = 'Tells you what music is currently playing'
    @commands = %w(playing)
  end

  def go(source, _args, bot)
    song = bot.mpd.current_song
    bot.say(self, source, "Current Song: #{song.artist} - #{song.title}")
  end
end

class QueueCommand < Plugin
  def initialize
    super
    @help_text = 'Prints how many songs are in the queue (including the currently playing song)'
    @commands = %w(queue)
  end

  def go(source, _args, bot)
    bot.say(self, source, "#{bot.mpd.queue.count} song(s) in queue")
  end
end

class Repeat < Plugin
  def initialize
    super
    @help_text = 'repeat (on/off)'
    @commands = %w(repeat)
  end

  def go(source, args, bot)
    if !args[0]
      if bot.mpd.repeat? == true
        bot.say(self, source, 'Repeat is currently on')
      else
        bot.say(self, source, 'Repeat is currently off')
      end
    elsif args[0].downcase == 'off'
      bot.mpd.repeat = false
      bot.mpd.single = false
      bot.mpd.consume = true
      bot.say(self, source, 'Repeat off')
    elsif args[0].downcase == 'on'
      bot.mpd.repeat = true
      bot.mpd.single = true
      bot.mpd.consume = false
      bot.say(self, source, 'Repeat on')
    end
  end
end

class Next < Plugin
  def initialize
    super
    @help_text = 'Advances to the next song in the queue.'
    @commands = %w(next advance)
  end

  def go(_source, _args, bot)
    bot.mpd.next
  end
end

class Volume < Plugin
  def initialize
    super
    @help_text = 'Change the volume - volume (level). No paramaters outputs the current volume.'
    @commands = %w(volume vol)
    @max_volume = 100
    @min_volume = 0
  end

  def go(source, args, bot)
    if args[0]
      if args[0][0] == '-'
        new_volume = bot.bot.player.volume - args[0].to_i.abs
      elsif args[0][0] == '+'
        new_volume = bot.bot.player.volume + args[0].to_i.abs
      else
        new_volume = args[0].to_i
      end
      if new_volume > @max_volume
        bot.say(self, source, "Volume can not exceed #{@max_volume}. Set to #{@max_volume}.")
        bot.bot.player.volume = @max_volume
      elsif new_volume < @min_volume
        bot.say(self, source, "Volume can not be lower than #{@min_volume}. Set to #{@min_volume}.")
        bot.bot.player.volume = @min_volume
      else
        bot.bot.player.volume = new_volume
      end
    else
      bot.say(self, source, "Volume is currently #{bot.bot.player.volume}")
    end
  end
end

class Clear < Plugin
  def initialize
    super
    @help_text = 'Stops anything playing, and clears the current playlist'
    @commands = %w(clear)
  end

  def go(_source, _args, bot)
    bot.mpd.clear
  end
end

class Pause < Plugin
  def initialize
    super
    @help_text = 'Pause the currently playing song'
    @commands = %w(pause)
  end

  def go(_source, _args, bot)
    bot.mpd.pause = true
  end
end

class Resume < Plugin
  def initialize
    super
    @help_text = 'Resume the currently playing song'
    @commands = %w(resume)
  end

  def go(_source, _args, bot)
    bot.mpd.pause = false
  end
end

class Remove < Plugin
  def initialize
    super
    @help_text = 'Remove the Xth song added to the queue - remove [X]. No parameters removes the last added song.'
    @commands = %w(remove delete)
  end

  def go(source, args, bot)
    if args[0]
      args[0] = args[0].to_i
      if args[0] <= bot.mpd.queue.count && args[0] > 0
        bot.mpd.delete(args[0] - 1)
        bot.say(self, source, "Song #{args[0]} removed. #{bot.mpd.queue.count} songs left in queue.")
      else
        bot.say(self, source, 'Song number not in range of queue.')
      end
    else
      bot.mpd.delete(bot.mpd.queue.count - 1)
      bot.say(self, source, "Last song removed. #{bot.mpd.queue.count} songs left in queue.")
    end
  end
end
