# Allows users to stream online radio from a pre-defined list (set in config.yml)
class Radio < Plugin
  def initialize
    super
    @help_text = 'Start streaming from online radio'
    @min_args = 0
    @commands = %w(radio)
    @radios = {}
  end

  def setup(_bot)
    @enabled = false if @radios.empty?
  end

  def go(source, args, bot)
    if args.empty?
      bot.say(self, source, 'Available radio stations: ')
      @radios.each_key do |key|
        bot.say(self, source, key)
      end
      return 0
    end

    station = args[0]

    if @radios[station].nil?
      bot.say(self, source, 'Radio not found. Use no arguments to view radio list.')
      return 0
    end

    bot.mpd.add(@radios[station])
    bot.mpd.play if bot.mpd.stopped?
  rescue => e
    bot.say(self, source, 'Failed to play stream. Is it down?')
    bot.say(self, source, e.message)
    return 1
  end
end
