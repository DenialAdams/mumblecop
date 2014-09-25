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

class DankThomas < Plugin
  def initialize
    @help_text = "Come on mothafuckas, come on!"
    @commands = ['thomas', 'biggie', 'dankengine']
    @dankness = ['ETfiUYij5UE']
    super
  end
  
  def go(source, args, bot)
    bot.commands['youtube'].go(source, @dankness.sample.split(' '), bot)
  end
end

class Ethan < Plugin
  def initialize
    @help_text = "༼ つ ◕_◕ ༽つ DU DUDUDUDUDUDUDUDUDU DU DU ༼ つ ◕_◕ ༽つ"
    @commands = ['ethan', 'stupid']
    @stupid = ['16RCvtziXj0']
    super
  end
  
  def go(source, args, bot)
    bot.commands['youtube'].go(source, @stupid.sample.split(' '), bot)
  end
end

class FuckYou < Plugin
  def initialize
    @help_text = "I won't do what you tell me"
    @commands = ['fuckyou', 'ratm', 'rage', 'anarchy']
    @anarchy_tunes = ['jPWYcjypSWo']
    super
  end
  
  def go(source, args, bot)
    bot.commands['youtube'].go(source, @anarchy_tunes.sample.split(' '), bot)
  end
end
