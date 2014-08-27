#!/bin/ruby
require 'mumble-ruby'
require 'sanitize'
require './plugins.rb'
$USERNAME = 'Robocop2.0'
$PASSWORD = 'eggs'
class MumbleBot
  attr_accessor :commands, :bot, :plugins
  def initialize
    @plugins = []
    @commands = {}
    @bot = Mumble::Client.new('localhost') do |conf|
      conf.username = $USERNAME
      conf.password = $PASSWORD
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
  end
  def say_to_user(id, text)
    @bot.text_user(id, text)
  end
  def say(plugin, source, text)
    if plugin.response == :user || plugin.response == :auto && source[0] == :user
      begin
        say_to_user(source[1], text)
      rescue # In case the user disconnects after sending the command but before receiving a response
      end
    elsif plugin.response == :channel || plugin.response == :auto && source[0] == :channel
      begin
        say_to_channel(source[1], text)
      rescue # In case the channel gets deleted, I guess
      end
    end
  end
  def fail(source, text)
    if source[0] == :user
      begin
        @bot.text_user(source[1], text)
      rescue
      end
    else
      begin
        @bot.text_channel(source[1], text)
      rescue
      end
    end
  end
  def load_plugins
    Dir["./plugins/*.rb"].each { |f| require f }
    Plugin.plugins.each do |klass|
      @plugins.push klass.new
    end
    @plugins.each do |plugin|
      plugin.commands.each do |command|
        @commands[command] = plugin
      end
    end
  end
  def register_callbacks
    @bot.on_text_message do |message|
      msg = message.message
      puts "#{get_username_from_id(message.actor)}: #{msg}"
      robocop_command = false
      if message.channel_id && msg.start_with?('robocop')
        msg = msg.split(' ')
        msg.delete_at(0)
        msg = msg.join(' ')
        source = [:channel, message.channel_id[0]]
        robocop_command = true
      elsif !message.channel_id
        robocop_command = true
        source = [:user, message.actor]
      end
      args = msg.split(' ')
      command = args[0]
      args.delete_at(0)
      if @commands[command].nil? && robocop_command
        fail(source, 'Command not found.')
      elsif robocop_command
        if @commands[command].min_args > args.length
          fail(source, "Command requires at least #{@commands[command].min_args} parameter(s).")
        else
          if @commands[command].needs_sanitization
            args = args.join('')
            args = Sanitize.fragment(args)
            args = args.split(' ')
          end
          @commands[command].go(source, args, self)
        end
      end
=begin
      elsif msg.start_with?('play') || msg.start_with?('resume')
        unless term.empty?
          system('mpc clear')
          system("mpc ls | grep #{term} | mpc add")
        end
        system('mpc play')
      elsif msg.start_with?('albums')
        robocop.text_user(message.actor, Dir.entries('/var/lib/mpd/music').to_s)
      elsif msg.start_with?('pause')
        system('mpc pause')
      elsif msg.start_with?('help')
        robocop.text_user(message.actor, 'i dunno fucking ask richard or some shit christ')
      elsif msg.start_with?('commands')
        robocop.text_user(message.actor, commands.to_s)
      end
=end
    end
    @bot.on_connected do
      @bot.player.volume = 5
      @bot.player.stream_named_pipe('/tmp/mpd.fifo')
    end
  end
end
robocop = MumbleBot.new
robocop.bot.connect
STDIN.gets
robocop.bot.disconnect
