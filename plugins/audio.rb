class Seek < Plugin
  def initialize
    super
    @help_text = 'Seek to x seconds in the currently playing media - seek [seconds]'
    @min_args = 1
    @commands = %w(seek)
  end

  def go(_source, args, bot)
    time = args[0].to_i
    bot.mpd.seek(time) if bot.mpd.playing?
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
    unless song
      bot.say(self, source, 'No song currently playing.')
      return 1
    end
    if song.artist.nil? && song.title.nil?
      bot.say(self, source, 'No song information available.')
      return
    elsif song.artist.nil?
      bot.say(self, source, "Current Song: #{song.title}")
    elsif song.title.nil?
      bot.say(self, source, "Current Song: #{song.artist} - Unknown title")
    else
      bot.say(self, source, "Current Song: #{song.artist} - #{song.title}")
    end
  end
end

class QueueCommand < Plugin
  def initialize
    super
    @help_text = 'Prints how many songs are in the queue (including the currently playing song.) If list is given as a parameter, lists the songs. If a number is given, list that song in the queue.'
    @commands = %w(queue q)
  end

  def go(source, args, bot)
    bot.say(self, source, "#{bot.mpd.queue.count} song(s) in queue.")
    if args.include?('list')
      bot.mpd.queue.each_with_index do |song, index|
        if index.zero?
          bot.say(self, source, "#{song.title} | Now Playing")
        else
          bot.say(self, source, "#{song.title} | #{index + 1}")
        end
      end
    elsif args[0]
      begin
        bot.say(self, source, bot.mpd.queue[args[0].to_i - 1].title)
      rescue
        bot.say(self, source, 'Requested queue number not in range')
      end
    end
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
        new_volume = bot.mumble.player.volume - args[0].to_i.abs
      elsif args[0][0] == '+'
        new_volume = bot.mumble.player.volume + args[0].to_i.abs
      else
        new_volume = args[0].to_i
      end
      if new_volume > @max_volume
        bot.say(self, source, "Volume can not exceed #{@max_volume}. Set to #{@max_volume}.")
        bot.mumble.player.volume = @max_volume
      elsif new_volume < @min_volume
        bot.say(self, source, "Volume can not be lower than #{@min_volume}. Set to #{@min_volume}.")
        bot.mumble.player.volume = @min_volume
      else
        bot.mumble.player.volume = new_volume
      end
    else
      bot.say(self, source, "Volume is currently #{bot.mumble.player.volume}")
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

class Crossfade < Plugin
  def initialize
    super
    @help_text = 'Set the crossfade between queued songs (in seconds)'
    @commands = %w(crossfade)
  end

  def go(source, args, bot)
    if args[0]
      bot.mpd.crossfade = args[0].to_i
    else
      if bot.mpd.crossfade.nil?
        crossfade = 0
      else
        crossfade = bot.mpd.crossfade
      end
      bot.say(self, source, "The crossfade is currently set to #{crossfade} seconds.")
    end
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
    @help_text = 'Remove the Xth song added to the queue - remove (X). No parameters removes the last added song.'
    @commands = %w(remove delete)
  end

  def go(source, args, bot)
    if args[0]
      args[0] = args[0].to_i
      if args[0] <= bot.mpd.queue.count && args[0] > 0
        song = bot.mpd.queue[args[0] - 1].title
        bot.mpd.delete(args[0] - 1)
        bot.say(self, source, "Song #{args[0]} - #{song} - removed. #{bot.mpd.queue.count} song(s) left in queue.")
      else
        bot.say(self, source, 'Song number not in range of queue.')
      end
    elsif bot.mpd.queue.count >= 1
      bot.mpd.delete(bot.mpd.queue.count - 1)
      bot.say(self, source, "Last song removed. #{bot.mpd.queue.count} song(s) left in queue.")
    else
      bot.say(self, source, 'No songs in queue.')
    end
  end
end

class Crop < Plugin
  def initialize
    super
    @help_text = 'Removes all songs from the queue but leaves the currently playing one.'
    @commands = %w(crop)
  end

  def go(source, _args, bot)
    if bot.mpd.queue.count > 1
      removed = 0
      until bot.mpd.queue.count == 1
        bot.mpd.delete(bot.mpd.queue.count - 1)
        removed += 1
      end
      boy.say(self, source, 'Cropped off #{removed} songs.')
    else
      bot.say(self, source, 'Nothing to crop.')
    end
  end
end
