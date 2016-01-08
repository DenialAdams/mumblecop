# Base plugin class, when it is inherited it will register itself into @plugins
class Plugin
  attr_accessor :help_text, :enabled, :protected, :response, :min_args,
                :needs_sanitization, :condition, :commands, :ignore_blacklist

  def self.plugins
    @plugins ||= []
  end

  def self.inherited(klass)
    @plugins ||= []
    @plugins << klass
  end

  def self.tick(bot, plugin_list)
    plugin_list.each do |plugin|
      plugin.update(bot)
    end
  end

  def initialize
    # default settings for every plugin; mostly self-explanatory
    # should the input be sanitized? (html stripped)
    @needs_sanitization = false
    @min_args = 0
    @enabled = true
    @help_text = 'No help text included for this command.'
    # auto, channel, user
    @response = :auto
    # allows some core plugins to be used by blacklisted users
    # generally set by a server admin, not by plugins themselves
    @ignore_blacklist = false
    # none, vote, trusted, trustedvote
    @condition = CONFIG['default-plugin-condition']
  end

  def setup(_bot)
    # Called once, when mumblecop starts.
    # Intended for plugins that only need to run something only once.
  end

  def go(_source, _args, _bot)
    # stub for now
  end

  def update(_bot)
    # stub for now
  end

  def on_text_received(bot, source, text)
    bot.say(self, source[2], text)
  end
end
