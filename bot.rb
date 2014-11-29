#!/usr/bin/env ruby

require 'mumble-ruby'
require 'sanitize'
require 'yaml'
require 'ruby-mpd'
require_relative 'plugins'

begin
  CONFIG = YAML.load_file('config.yml') unless defined? CONFIG
  rescue Errno::ENOENT
    abort 'config.yml not found. Copy, edit and rename config-sample.yml if this has not yet been done.'
end
STDOUT.sync = true

# The mumblebot recieves and validates commands,
# then proceeds to pass those off to plugins.
class MumbleBot
  attr_accessor :commands, :bot, :plugins, :mpd

  def initialize
    @plugins = []
    @commands = {}
    @bot = Mumble::Client.new(CONFIG['address']) do |conf|
      conf.username = CONFIG['username']
      conf.password = CONFIG['password'] if CONFIG['password']
    end
    load_plugins
    register_callbacks
  end

  def current_channel
    @bot.me.channel_id.to_i
  end

  def get_username_from_id(id)
    @bot.users[id].name
  end

  def say_to_channel(channel, text)
    @bot.text_channel(channel, text)
  rescue
    return 1
  end

  def say_to_user(id, text)
    @bot.text_user(id, text)
  rescue
    return 1
  end

  def say(plugin, source, text)
    if plugin.response == :user || plugin.response == :auto && source[0] == :user
      say_to_user(source[1], text)
    else
      say_to_channel(source[1], text)
    end
  end

  def fail(source, text)
    if source[0] == :user
      say_to_user(source[1], text)
    else
      say_to_channel(source[1], text)
    end
  end

  def load_plugins
    Dir['./plugins/*.rb'].each { |file| require file }
    Plugin.plugins.each do |klass|
      @plugins.push klass.new
    end
    @plugins.each do |plugin|
      plugin.commands.each do |command|
        @commands[command] = plugin
      end
    end
  end

  def matches_trigger(string)
    CONFIG['triggers'].include?(string.split(' ')[0].downcase)
  end

  def sanitize_params(params)
    params = Sanitize.fragment(params.join(' '))
    params.split(' ')
  end

  # needs rewrite
  def process_message(message)
    contents = message.message
    puts "#{get_username_from_id(message.actor)}: #{contents}"
    return if contents.strip.empty?
    mumblecop_command = false
    if message.channel_id && matches_trigger(contents)
      contents = contents.split(' ')
      contents.delete_at(0)
      contents = contents.join(' ')
      source = [:channel, message.channel_id[0]]
      mumblecop_command = true
    elsif !message.channel_id
      if matches_trigger(contents)
        contents = contents.split(' ')
        contents.delete_at(0)
        contents = contents.join(' ')
      end
      mumblecop_command = true
      source = [:user, message.actor]
    end
    args = contents.split(' ')
    if args.length == 0
      fail(source, 'A command is required proceeding a mumblecop trigger')
      return
    end
    process_command(args.delete_at(0).downcase, mumblecop_command, args, source)
  end

  # needs rewrite
  def process_command(command, mumblecop_command, args, source)
    if @commands[command].nil? && mumblecop_command
      fail(source, 'Command not found.')
    elsif mumblecop_command
      if !@commands[command].enabled
        fail(source, 'Command is currently disabled. Ask an administrator for details.')
      elsif @commands[command].min_args > args.length
        fail(source, "Command requires #{@commands[command].min_args} parameter(s).")
      else
        args = sanitize_params(args) if @commands[command].needs_sanitization
        Thread.new { @commands[command].go(source, args, self) }
      end
    end
  end

  def setup
    @bot.player.volume = CONFIG['initial-volume']
    @bot.player.stream_named_pipe(CONFIG['mpd-pipe-location'])
    @bot.set_comment(CONFIG['comment'])
    @mpd = MPD.new CONFIG['mpd-address'], CONFIG['mpd-port']
    @mpd.connect
    @mpd.consume = true
  end

  def configure_plugins
    # todo: sort so we don't have to double iterate
    PLUGIN_LIST.each do |plugin|
      CONFIG['plugins'].each do |plugin_name, options|
        if plugin_name == plugin.class.to_s.downcase
          options.each do |option, value|
            plugin.instance_variable_set("@#{option}", value)
          end
        end
      end
    end
  end

  def register_callbacks
    @bot.on_text_message do |message|
      process_message(message)
    end
    @bot.on_connected do
      setup
    end
  end
end
mumblecop = MumbleBot.new
mumblecop.bot.connect
PLUGIN_LIST = mumblecop.commands.values.uniq
mumblecop.configure_plugins
loop do
  sleep(CONFIG['plugin-update-rate'])
  Plugin.tick(mumblecop, PLUGIN_LIST)
end
