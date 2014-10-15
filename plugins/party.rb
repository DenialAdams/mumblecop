require 'active_support/all'

class Party < Plugin
  def initialize
    super
    @party_time = choose_party_time
    @party_volume = 50 # <0 = don't change the volume
    @party_music = ['QH2-TGUlwu4', 'LDZX4ooRsWs']
    @commands = ['party']
  end

  def choose_party_time
    (Date.today + rand(0..7).day + rand(19..22).hour + rand(0..60).minutes).to_datetime
  end

  def play_music(bot)
    bot.commands['youtube'].go([:user, bot.bot.me], @party_music.sample.split(' '), bot)
  end

  def go(source, _args, bot)
    bot.say(self, source, @party_time.to_s)
    # @go = true
  end

  def update(bot)
    if Time.now > @party_time || @go == true
      system('mpc clear')
      bot.bot.player.volume = @party_volume if @party_volume > 0
      bot.say_to_channel(bot.current_channel, 'START THE MOTHERFUCKING PARTY')
      play_music(bot)
      @party_time = choose_party_time
      @go = false
    end
  end
end
