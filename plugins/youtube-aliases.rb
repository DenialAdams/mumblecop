class Elevator < Plugin
  def initialize
    @help_text = "Plays some relaxing waiting tunes"
    @commands = ['elevator', 'lobby']
    @elevator_tunes = ['zG456vqPHJo']
    super
  end

  def go(source, args, bot)
    bot.commands['youtube'].go(source, @elevator_tunes.sample.split(' '), bot)
  end
end

class HateTrain < Plugin
  def initialize
    @help_text = "Haaaaaaaaaaaaaaaaaaaaaaaaaaaaaaate is a train..."
    @commands = ['dan']
    @hate_tunes = ['Q27SGo-fMhs']
    super
  end

  def go(source, args, bot)
    bot.commands['youtube'].go(source, @hate_tunes.sample.split(' '), bot)
  end
end

class JamesOhShit < Plugin
  def initialize
    @help_text = "Shiiiiit"
    @commands = ['james']
    @song = ['zi44BM1YHf8']
    super
  end
  
  def go(source, args, bot)
    bot.commands['youtube'].go(source, @song.sample.split(' '), bot)
  end
end

class JebSpoopy < Plugin
  def initialize
    @help_text = "SPOOPY"
    @commands = ['jeb']
    @song = ['wEE_CY1XKTg']
    super
  end

  def go(source, args, bot)
    bot.commands['youtube'].go(source, @song.sample.split(' '), bot)
  end

end
