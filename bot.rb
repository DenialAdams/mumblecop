#!/usr/bin/env ruby
require 'mumble-ruby'
require 'sanitize'
require 'yaml'
require './plugins.rb'
CONFIG = YAML.load_file('config.yml') unless defined? CONFIG
STDOUT.sync = true
class MumbleBot
  attr_accessor :commands, :bot, :plugins

  def initialize
    @plugins = []
    @commands = {}
    @bot = Mumble::Client.new('localhost') do |conf|
      conf.username = CONFIG['username']
      conf.password = CONFIG['password'] unless CONFIG['password'].nil?
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
    elsif plugin.response == :channel || plugin.response == :auto && source[0] == :channel
      say_to_channel(source[1], text)
    end
  end

  def fail(source, text)
    if source[0] == :user
      say_to_channel(source[1], text)
    else
      say_to_channel(source[1], text)
    end
  end

  def load_plugins
    Dir['./plugins/*.rb'].each { |f| require f }
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
    CONFIG['triggers'].each do |trigger|
      return true if string.split(' ')[0].downcase == trigger
    end
    false
  end

  def register_callbacks
    @bot.on_text_message do |message|
      msg = message.message
      puts "#{get_username_from_id(message.actor)}: #{msg}"
      robocop_command = false
      if message.channel_id && matches_trigger(msg)
        msg = msg.split(' ')
        msg.delete_at(0)
        msg = msg.join(' ')
        source = [:channel, message.channel_id[0]]
        robocop_command = true
      elsif !message.channel_id
        if matches_trigger(msg)
          msg = msg.split(' ')
          msg.delete_at(0)
          msg = msg.join(' ')
        end
        robocop_command = true
        source = [:user, message.actor]
      end
      args = msg.split(' ')
      command = args[0].downcase
      args.delete_at(0)
      if @commands[command].nil? && robocop_command
        fail(source, 'Command not found.')
      elsif robocop_command
        if !@commands[command].enabled
          fail(source, 'Command is currently disabled. Ask an administrator for details.')
        elsif @commands[command].min_args > args.length
          fail(source, "Command requires at least #{@commands[command].min_args} parameter(s).")
        else
          if @commands[command].needs_sanitization
            args = args.join('')
            args = Sanitize.fragment(args)
            args = args.split(' ')
          end
          Thread.new { @commands[command].go(source, args, self) }
        end
      end
    end
    @bot.on_connected do
      @bot.player.volume = 5
      @bot.player.stream_named_pipe('/tmp/mpd.fifo')
      @bot.set_comment(CONFIG['comment'])
      system('mpc consume on')
    end
  end
end
robocop = MumbleBot.new
robocop.bot.connect
loop do
  sleep(0.1)
end
