class Countdown < Plugin
  def initialize
    super
    @help_text = 'Counts down from X to STOP - countdown [X] [interval]'
    @commands = %w(countdown cd)
    @min_args = 1
  end

  def go(source, args, bot)
    end_number = args[0].to_i
    if args[1]
      interval = args[1].to_i
    else
      interval = 1
    end
    if end_number > 0
      end_number.downto(1) do |i|
        bot.say(self, source, i.to_s) if i % interval == 0
        sleep(1)
      end
      bot.say(self, source, 'STOP')
    else
      bot.say(self, source, 'The number must be greater than zero')
    end
  end
end
