# Assigns a number to each user.
# Can be done to each user privately, or as a master list
class Assign < Plugin
  def initialize
    super
    @help_text = 'Send each user on the server a unique number randomly, starting at one and going up. If the list option is given, a master list will be provided instead of messaging the users. Send and list can both be given as arguments to get a list and send every user their number. If channel is given as an argument it will only consider users in the channel of the bot.'
    @commands = %w(assign)
  end

  def go(source, _command, args, bot)
    send = false
    master_list = false
    channel_only = false
    args.each do |arg|
      master_list = true if arg.casecmp('list').zero?
      send = true if arg.casecmp('send').zero?
      channel_only = true if arg.casecmp('channel').zero?
    end
    send = true unless master_list
    # other users = all users except the one that is me
    # for some reason array subtraction did not work
    if channel_only
      other_users = bot.mumble.users.values.reject { |c| c == bot.mumble.me || c.channel_id != bot.mumble.me.channel_id }
    else
      other_users = bot.mumble.users.values.reject { |c| c == bot.mumble.me }
    end
    hash = {}
    i = 1
    other_users.shuffle.each do |user|
      hash[i] = user
      i += 1
    end
    if master_list
      message = ''
      hash.each do |k, v|
        message += '<p>'.concat(v.name).concat(' - ').concat(k.to_s).concat('</p>')
      end
      message = message.chomp
      bot.say(self, source, message)
    end
    return 0 unless send
    hash.each do |k, v|
      bot.say_to_user(v, "Your unique number is #{k}")
    end
    0
  end
end
