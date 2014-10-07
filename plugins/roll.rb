require 'dicebag'

class Roll < Plugin
  def initialize
    @min_args = 1
    @commands = ['roll']
    @help_text = 'Roll some dice - 4d5 - see the dicebag ruby gem online for formatting.'
    super
  end

  def go(source, args, bot)
    result = DiceBag::Roll.new(args.join(' ')).result
    bot.say(self, source, result.to_s)
    rescue DiceBag::DiceBagError
      bot.say(self, source, 'Error parsing roll command. Format = \'xdy\'. Numbers must be less than 4 digits.')
  end
end
