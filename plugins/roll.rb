require 'dicebag'

class Roll < Plugin
  def initialize
    @min_args = 1
    @commands = ['roll']
    @help_text = 'Roll some dice - see the dicebag ruby gem online for formatting.'
    super
  end

  def go(source, args, bot)
    result = DiceBag::Roll.new(args.join(' ')).result
      rescue DiceBag::DiceBagError
        bot.say(self, source, 'Error parsing roll command. Numbers must be less than 4 digits.')
        bot.say(self, source, result.to_s)
  end
end
