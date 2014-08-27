class Elevator < Plugin
  def initialize
    @help_text = "Plays some relaxing waiting tunes"
    @commands = ['elevator', 'lobby']
    @elevator_tunes = ['zG456vqPHJo']
    super
  end

  def go(source, args, bot)
    bot.commands['youtube'].go(source, @elevator_tunes.sample, bot)
  end
end

class HateTrain < Plugin
  def initialize
    @help_text = "Haaaaaaaaaaaaaaaaaaaaaaaaaaaaaaate is a train..."
    @commands = ['dan']
    @hate_tunes = ['Q27SGo-fMhsi']
    super
  end

  def go
    bot.commands['youtube'].go(source, @hate_tunes.sample, bot)
  end
end
