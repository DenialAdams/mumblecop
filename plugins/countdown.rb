class Countdown < Plugin
  def initialize
    super
    @help_text = 'Counts down from X to STOP - countdown [X]'
    @commands = %w(countdown cd)
  end

  def go(source, args, bot)
    end_number = args[0].to_i
    if end_number > 0
      end_number.downto(1) do |i|
        bot.say(self, source, i.to_s)
        sleep(1)
      end
      bot.say(self, source, 'STOP')
    else
      bot.say(self, source, 'The number must be greater than zero')
    end
  end
end
