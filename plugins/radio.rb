# Allows users to stream online radio from a pre-defined list (set in config.yml)
class Radio < Plugin
  def initialize
    super
    @help_text = 'Start streaming from an online radio station.'
    @min_args = 0
    @commands = %w(radio)
    @stations = {}
  end

  def setup(_bot)
    # The radio plugin is useless with no stations, so we just disable ourselves
    @enabled = false if @stations.empty?
  end

  def go(source, _command, args, bot)
    if args.empty?
      bot.say(self, source, 'Available radio stations: ')
      @stations.each_key do |key|
        bot.say(self, source, key)
      end
      return 0
    end

    station = args[0]

    if @stations[station].nil?
      bot.say(self, source, 'Station not found. Use no arguments to view the station list.')
      return 1
    end

    bot.mpd.add(@stations[station])
    bot.mpd.play if bot.mpd.stopped?
  rescue => e
    bot.say(self, source, 'Failed to play station. Is it down?')
    bot.say(self, source, e.message)
    return 1
  end
end
