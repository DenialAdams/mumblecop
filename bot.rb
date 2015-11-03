#!/usr/bin/env ruby

# used for our config file
require 'yaml'
# the basis of the whole application
require 'mumble-ruby'
# used for sanitizing arguments passed to plugins (when set in the plugin)
require 'sanitize'
require 'active_support/core_ext/string'
# used for all audio related features
require 'ruby-mpd'
require_relative 'plugins'

begin
  CONFIG = YAML.load_file('config.yml') unless defined? CONFIG
rescue Errno::ENOENT
  abort 'config.yml not found. Copy, edit and rename config-sample.yml if this has not yet been done.'
end

STDOUT.sync = true

# The mumblebot recieves and validates commands, then proceeds to pass those off to plugins.
class MumbleBot
  attr_accessor :commands, :mumble, :plugins, :mpd
  attr_reader :trusted_users, :blacklisted_users, :setup_completed

  def initialize(mumble_client = nil)
    @plugins = []
    @commands = {}
    mumble_client ||= Mumble::Client.new(CONFIG['address'], CONFIG['port']) do |conf|
      conf.username = CONFIG['username']
      conf.password = CONFIG['password'] if CONFIG['password']
      conf.bitrate = CONFIG['bitrate'] if CONFIG['bitrate']
      conf.sample_rate = CONFIG['sample_rate'] if CONFIG['sample_rate']
    end
    @mumble = mumble_client
    load_plugins
    register_callbacks
  end

  def current_channel
    @mumble.me.channel_id.to_i
  end

  def get_username_from_id(id)
    @mumble.users[id].name
  end

  def get_username_from_source(source)
    if source[0] == :channel
      @mumble.users[source[2]].name
    else
      @mumble.users[source[1]].name
    end
  end

  def get_hash_from_id(id)
    @mumble.users[id].hash
  end

  def get_hash_from_source(source)
    if source[0] == :channel
      @mumble.users[source[2]].hash
    else
      @mumble.users[source[1]].hash
    end
  end

  def say_to_current_channel(text)
    say_to_channel(current_channel, text)
  end

  def say_to_channel(channel, text)
    @mumble.text_channel(channel, text)
  rescue => e
    puts "ERROR: Failed to message channel with ID of #{channel}. Invalid channel?"
    puts e.message
    return 1
  end

  def say_to_user(id, text)
    @mumble.text_user(id, text)
  rescue => e
    puts "ERROR: Failed to message user with ID of #{id}. Invalid user?"
    puts e.message
    return 1
  end

  def say(plugin, source, text)
    if plugin.response == :user || plugin.response == :auto && source[0] == :user
      if source[0] == :channel
        say_to_user(source[2], text)
      else
        say_to_user(source[1], text)
      end
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
      next unless plugin.commands
      plugin.commands.each do |command|
        @commands[command] = plugin
      end
    end
  end

  def reload_permissions
    @trusted_users = File.readlines('trusted-users.txt').map(&:chomp)
    @blacklisted_users = File.readlines('blacklisted-users.txt').map(&:chomp)
  end

  def setup
    @mumble.player.volume = CONFIG['initial-volume']
    @mumble.set_comment(CONFIG['comment_text']) if CONFIG['comment'] == :text
    reload_permissions
    return unless CONFIG['use-mpd']
    @mumble.player.stream_named_pipe(CONFIG['fifo-pipe-location'])
    @mpd = MPD.new CONFIG['mpd-address'], CONFIG['mpd-port'], callbacks: CONFIG['mpd-callbacks']
    @mpd.connect
    @mpd.consume = true
  end

  def configure_plugins(list)
    list.each do |plugin|
      if CONFIG['plugins'] && CONFIG['plugins'][plugin.class.to_s.downcase]
        CONFIG['plugins'][plugin.class.to_s.downcase].each do |option, value|
          plugin.instance_variable_set("@#{option}", value)
        end
      end
      plugin.setup(self)
    end
  end

  # error codes:
  # 1: invalid command
  # 2: command disabled
  # 3: user blacklisted
  # 4: command requires trusted status
  # 5: minimum arguments not satisfied
  def run_command(command, args, source, multithread: CONFIG['multithread-commands'])
    return 1 if @commands[command].nil?
    user_hash = get_hash_from_source(source)
    if !@commands[command].enabled
      return 2
    elsif @blacklisted_users.include?(user_hash) && !@commands[command].ignore_blacklist
      return 3
    elsif @commands[command].condition == :trusted && !@trusted_users.include?(user_hash)
      return 4
    elsif @commands[command].min_args > args.length
      return 5
    else
      args = sanitize_params(args) if @commands[command].needs_sanitization
      if multithread
        Thread.new { @commands[command].go(source, args, self) }
      else
        @commands[command].go(source, args, self)
      end
    end
  end

  private

  def register_callbacks
    @mumble.on_text_message do |message|
      process_message(message)
    end
    @mumble.on_connected do
      setup
      @setup_completed = true
    end
  end

  def matches_trigger(string)
    CONFIG['triggers'].include?(string.split(' ')[0].downcase)
  end

  def sanitize_params(params)
    params = Sanitize.fragment(params.join(' '))
    params.split(' ')
  end

  def strip_trigger(command)
    command = command.split(' ')
    command.delete_at(0)
    command.join(' ')
  end

  def process_message(message)
    contents = message.message.chomp.gsub('&quot;', '"')
    if CONFIG['verbose-chat-log']
      puts "#{get_hash_from_id(message.actor)} | #{get_username_from_id(message.actor)}: #{contents}"
    else
      puts "#{get_username_from_id(message.actor)}: #{contents}"
    end
    return if contents.strip.empty?
    possible_commands = contents.split(';').reject(&:blank?)
    possible_commands.each_with_index do |command, i|
      next if i == 0 || matches_trigger(command.split(' ')[0])
      possible_commands[i - 1] = possible_commands[i - 1].concat(";#{command}")
    end
    possible_commands.reverse_each do |command|
      mumblecop_command = false
      if message.channel_id && matches_trigger(command)
        command = strip_trigger(command) if matches_trigger(command)
        mumblecop_command = true
        source = [:channel, message.channel_id[0], message.actor]
      elsif !message.channel_id
        command = strip_trigger(command) if matches_trigger(command)
        mumblecop_command = true
        source = [:user, message.actor]
      end
      next unless mumblecop_command
      args = command.split(' ')
      if args.length.zero?
        command_fail(source, 'A command is required proceeding a mumblecop trigger')
        next
      end
      process_command(args.delete_at(0).downcase, args, source)
    end
  end

  def process_command(command, args, source)
    case run_command(command, args, source)
    when 1
      command_fail(source, 'Command not found.')
    when 2
      command_fail(source, 'Command is currently disabled. Ask an administrator for details.')
    when 3
      command_fail(source, 'You have been banned from mumblecop usage on this server.')
    when 4
      command_fail(source, 'You must be a trusted user in order to use this command.')
    when 5
      command_fail(source, "Command requires #{@commands[command].min_args} parameter(s).")
    end
  end

  def command_fail(source, text)
    if source[0] == :user
      say_to_user(source[1], text)
    else
      say_to_channel(source[1], text)
    end
    1
  end
end

mumblecop = MumbleBot.new
mumblecop.mumble.connect
sleep(0.1) until mumblecop.setup_completed
PLUGIN_LIST = mumblecop.plugins
mumblecop.configure_plugins(PLUGIN_LIST)
loop do
  sleep(CONFIG['plugin-update-rate'])
  Plugin.tick(mumblecop, PLUGIN_LIST)
end
