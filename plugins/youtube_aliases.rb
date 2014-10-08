class Elevator < Plugin
  def initialize
    super
    @help_text = 'Plays some relaxing waiting tunes'
    @commands = %w(elevator lobby)
    @song = ['zG456vqPHJo']
  end

  def go(source, _args, bot)
    bot.commands['youtube'].go(source, @song, bot)
  end
end

class HateTrain < Plugin
  def initialize
    super
    @help_text = 'Haaaaaaaaaaaaaaaaaaaaaaaaaaaaaaate is a train...'
    @commands = ['dan']
    # second arg is seek time, not currently used
    @song = ['Q27SGo-fMhs', '70']
  end

  def go(source, _args, bot)
    bot.commands['youtube'].go(source, @song, bot)
  end
end

class JamesOhShit < Plugin
  def initialize
    super
    @help_text = 'Shiiiiit'
    @commands = ['james']
    @song = ['zi44BM1YHf8']
  end

  def go(source, _args, bot)
    bot.commands['youtube'].go(source, @song, bot)
  end
end

class JebSpoopy < Plugin
  def initialize
    super
    @help_text = 'SPOOPY'
    @commands = ['jeb']
    @song = ['wEE_CY1XKTg']
  end

  def go(source, _args, bot)
    bot.commands['youtube'].go(source, @song, bot)
  end
end

class DankThomas < Plugin
  def initialize
    super
    @help_text = 'Come on mothafuckas, come on!'
    @commands = %w(thomas biggie dankengine)
    @song = ['ETfiUYij5UE']
  end

  def go(source, _args, bot)
    bot.commands['youtube'].go(source, @song, bot)
  end
end

class Ethan < Plugin
  def initialize
    super
    @help_text = '༼ つ ◕_◕ ༽つ DU DUDUDUDUDUDUDUDUDU DU DU ༼ つ ◕_◕ ༽つ'
    @commands = %w(ethan stupid)
    @song = ['16RCvtziXj0']
  end

  def go(source, _args, bot)
    bot.commands['youtube'].go(source, @song, bot)
  end
end

class FuckYou < Plugin
  def initialize
    super
    @help_text = "I won't do what you tell me"
    @commands = %w(fuckyou ratm rage anarchy)
    @song = ['jPWYcjypSWo']
  end

  def go(source, _args, bot)
    bot.commands['youtube'].go(source, @song, bot)
  end
end

class Cantina < Plugin
  def initialize
    super
    @help_text = 'Han shot first'
    @commands = %w(cantina starwars)
    @song = ['stbYF6XpTYE']
  end

  def go(source, _args, bot)
    bot.commands['youtube'].go(source, @song, bot)
  end
end

class SpookySkeletons < Plugin
  def initialize
    super
    @help_text = 'Spooby scurry skellingtons'
    @commands = %w(spooky skeletons spoopy)
    @song = ['q6-ZGAGcJrk', 'K2rwxs1gH9w']
  end

  def go(source, _args, bot)
    bot.commands['youtube'].go(source, @song.sample.split(' '), bot)
  end
end

class TomNook < Plugin
  def initialize
    super
    @help_text = "Hey kid, wanna house? It'll only put you in debt to me for the next 50 quadrillion years"
    @commands = %w(tomnook nook)
    @song = ['t1svDZECOa4']
  end

  def go(source, _args, bot)
    bot.commands['youtube'].go(source, @song, bot)
  end
end

class Best < Plugin
  def initialize
    super
    @help_text = 'For when you need a pick me up'
    @commands = %w(best)
    @song = ['2F2i6EQsPZY']
  end

  def go(source, _args, bot)
    bot.commands['youtube'].go(source, @song, bot)
  end
end
