require 'dicebag'

# Command that uses the dicebag gem for dice rolling, very useful for roleplaying games or if you are bad at deciding things
class Roll < Plugin
  def initialize
    super
    @min_args = 1
    @commands = %w(roll)
    @help_text = 'Roll some dice - 4d5 - see the dicebag ruby gem online for formatting.'
  end

  def go(source, args, bot)
    result = DiceBag::Roll.new(args.join(' ')).result
    bot.say(self, source, result.to_s)
    rescue DiceBag::DiceBagError
      bot.say(self, source, 'Error parsing roll command. Format = \'xdy\'. Numbers must contain less than 4 digits.')
  end
end
