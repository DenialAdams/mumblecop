#!/usr/bin/env ruby

abort 'ERROR: Mumblecop requires Ruby version 2.0 or greater to run.' if RUBY_VERSION.to_f < 2.0

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
  abort 'ERROR: config.yml not found. Copy, edit and rename config-sample.yml if this has not yet been done.'
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
    # we don't want to modify the source when pulling the hash
    source = source.clone
    source.shift(2) while source[0] == :plugin
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
    STDERR.puts "ERROR: Failed to message channel with ID of #{channel}. Invalid channel?"
    STDERR.puts e.message
    return 1
  end

  def say_to_user(id, text)
    @mumble.text_user(id, text)
  rescue => e
    STDERR.puts "ERROR: Failed to message user with ID of #{id}. Invalid user?"
    STDERR.puts e.message
    return 1
  end

  def say(plugin, source, text)
    if source[0] == :plugin
      source[1].on_text_received(self, source, text)
    elsif plugin.response == :user || plugin.response == :auto && source[0] == :user
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
    abort 'ERROR: use-mpd set to on but fifo pipe as specified in fifo-pipe location does not seem to exist. Is mpd running and is fifo-pipe-location set correctly?' unless File.exist?(CONFIG['fifo-pipe-location'])
    @mumble.player.stream_named_pipe(CONFIG['fifo-pipe-location'])
    @mpd = MPD.new CONFIG['mpd-address'], CONFIG['mpd-port'], callbacks: CONFIG['mpd-callbacks']
    @mpd.connect
    STDERR.puts 'WARNING: Your MPD version is detected to be very out of date and will likely not work properly.' if @mpd.version.to_f < 0.19
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
  def run_command(command, args, source, multithread: false, obey_source_permissions: true, obey_enabled_status: true)
    # we return everything in the form of [code, result]
    # returning 0 only means the command was _called_ successfully, it can still fail
    return [1, nil] if @commands[command].nil?
    return [2, nil] if !@commands[command].enabled && obey_enabled_status
    return [5, nil] if @commands[command].min_args > args.length
    user_hash = get_hash_from_source(source)
    return [3, nil] if @blacklisted_users.include?(user_hash) && !commands[command].ignore_blacklist && obey_source_permissions
    return [4, nil] if @commands[command].condition == :trusted && !@trusted_users.include?(user_hash) && obey_source_permissions
    args = sanitize_params(args) if @commands[command].needs_sanitization
    if multithread
      Thread.new do
        begin
          @commands[command].go(source, command, args, self)
        rescue ArgumentError
          STDERR.puts "WARNING: Plugin '#{@commands[command].class.name}' needs to be updated with the new go message signature or it will cease to function in an upcoming release."
          @commands[command].go(source, args, self)
        end
      end
      # the result can not be relied upon if using multithreading
      return [0, nil]
    else
      begin
        @commands[command].go(source, command, args, self)
      rescue ArgumentError
        STDERR.puts "WARN: Plugin #{@commands[command]} needs to be updated with the new go message signature or it will cease to function in an upcoming release."
        @commands[command].go(source, args, self)
      end
      return [0, result]
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
      next if i.zero? || matches_trigger(command.split(' ')[0])
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
    case run_command(command, args, source, multithread: CONFIG['multithread-commands'])[0]
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
