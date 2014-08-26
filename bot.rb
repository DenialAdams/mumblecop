#!/bin/ruby
require 'mumble-ruby'
require 'sanitize'
require './plugins.rb'
$USERNAME = 'Robocop2.0'
$PASSWORD = 'eggs'
class MumbleBot
  attr_accessor :commands, :bot
  def initialize
    @commands = ['fuck', 'play/resume', 'volume', 'albums', 'roll', 'say', 'stop', 'pause', 'youtube', 'lobby/elevator', 'commands', 'help', 'date/time'].shuffle
    @bot = Mumble::Client.new('localhost') do |conf|
      conf.username = $USERNAME
      conf.password = $PASSWORD
    end
    load_commands
    register_callbacks
  end
  def get_username_from_id(id)
    @bot.users[id].name
  end
  def current_channel
    @bot.me.channel_id
  end
  def say_to_channel(channel, text)
    @bot.text_channel(channel, text)
  end
  def say_to_user(id, text)
    @bot.text_user(id, text)
  end
  def load_commands
    Dir["./plugins/*.rb"].each { |f| require f }
  end
  def register_callbacks
    @bot.on_text_message do |message|
      msg = message.message
      puts "#{get_user_from_id(robocop, message.actor)}: #{msg}"
      robocop_command = false
      if message.channel_id && msg.start_with?('robocop')
        msg = msg.split(' ')
        msg.delete_at(0)
        msg = msg.join(' ')
        robocop_command = true
      end
      args = msg.split(' ')
      args.delete_at(0)
      args = args.join(' ')
=begin
      if message.channel_id && !robocop_command
        # nothing
      elsif msg.start_with?('play') || msg.start_with?('resume')
        unless term.empty?
          system('mpc clear')
          system("mpc ls | grep #{term} | mpc add")
        end
        system('mpc play')
      elsif msg.start_with?('fuck')
        if term == $USERNAME
          robocop.text_user(message.actor, 'No, fuck you')
        else
          begin
            robocop.text_user(term, 'Someone anonymously says fuck you.')
            robocop.text_user(message.actor, 'Message delivered!')
          rescue
            robocop.text_user(message.actor, 'Sorry, user not found.')
          end
        end
      elsif msg.start_with?('volume')
        if term.empty?
          robocop.text_user(message.actor, robocop.player.volume.to_s)
        else
          robocop.player.volume = term.to_i
        end
      elsif msg.start_with?('roll')
        if message.channel_id && robocop_command
          robocop.text_channel(robocop.channels[0], rand(1..term.to_i).to_s)
        else
          robocop.text_user(message.actor, rand(1..term.to_i).to_s)
        end
      elsif msg.start_with?('albums')
        robocop.text_user(message.actor, Dir.entries('/var/lib/mpd/music').to_s)
      elsif msg.start_with?('say')
        robocop.text_channel(robocop.channels[0], term)
      elsif msg.start_with?('stop')
        system('mpc clear')
      elsif msg.start_with?('pause')
        system('mpc pause')
      elsif msg.start_with?('date') || msg.start_with?('time')
        robocop.text_user(message.actor, `date`)
      elsif msg.start_with?('youtube')
        term = Sanitize.fragment(term) # to strip the html that mumble likes to throw into things
        system('mpc clear')
        result = system('get_youtube', term)
        if result
          system('mpc play')
        else
          robocop.text_user(message.actor, 'Failed to play video. Check given url.')
        end
      elsif msg.start_with?('lobby') || msg.start_with?('elevator')
        elevator_music = ['zG456vqPHJo']
        system('mpc clear')
        system('get_youtube', elevator_music.sample)
        system('mpc play')
      elsif msg.start_with?('help')
        robocop.text_user(message.actor, 'i dunno fucking ask richard or some shit christ')
      elsif msg.start_with?('commands')
        robocop.text_user(message.actor, commands.to_s)
      else
        robocop.text_user(message.actor, 'command not recognized')
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
