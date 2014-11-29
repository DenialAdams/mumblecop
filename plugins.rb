# Base plugin class, when it is inherited it will register itself into @plugins
class Plugin
  attr_accessor :help_text, :enabled, :protected, :response, :min_args,
                :needs_sanitization, :commands

  def self.plugins
    @plugins ||= []
  end

  def self.inherited(klass)
    @plugins ||= []
    @plugins << klass
  end

  def update(_bot)
    # stub for now
  end

  def self.tick(bot, plugin_list)
    plugin_list.each do |plugin|
      plugin.update(bot)
    end
  end

  def initialize
    @needs_sanitization = false
    @min_args = 0
    @enabled = true
    @protected = false # does nothing yet
    @help_text = 'No help text included for this command'
    @response = :auto
  end

  def go
    # stub for now
  end
end