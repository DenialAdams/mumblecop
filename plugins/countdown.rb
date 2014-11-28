class Countdown < Plugin
  def initialize
    super
    @help_text = 'Counts down from X to STOP - countdown [X]'
    @commands = %w(countdown cd)
  end

  def go(source, args, bot)
    if args[0] > 0
      while args[0] > 0
        bot.say(self, source, "#{args[0]}")
        args[0] = args[0] - 1
        sleep(1)
      end
      bot.say(self, source, "STOP")
    end
  end
end
