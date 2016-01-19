require 'rubystats'
require 'ostruct'
require 'pp'
require 'roo'

require_relative 'stronghold'
require_relative 'defenses'
require_relative 'base_robot'
require_relative 'high_goal_cycle'
require_relative 'defender'
require_relative 'clear_and_pass'
require_relative 'clear_and_shoot'

class Simulation
  GAMES_FILE = 'games.xlsx'
  ROBOTS_FILE = 'robotstats.xlsx'

  class << self
    def set_stats(stats)
      @stats = stats
    end

    def get_robot_stats(name)
      @stats[name]
    end
  end

  def initialize(game_name)
    read_stats
    @stronghold = Stronghold.new
    read_game(game_name)
  end

  def read_game(name)
    xlsx = Roo::Spreadsheet.open('games.xlsx')
    sheet = xlsx.sheet(name)

    red = []
    blue = [] 
    (4..6).to_a.each do |row|
      data = sheet.row(row)
      red << build_robot(*data[0..1])
      blue << build_robot(*data[2..3])
    end

    @stronghold.blue_alliance(*blue)
    @stronghold.red_alliance(*red)
  end

  def build_robot(stats, strategy)
    if robot_stats(stats).nil?
      raise "Unable to execute game, missing stats: #{stats}"
    end
   
    klass = strategy.strip.downcase.gsub(/[ _]+([a-z])/) { $1.upcase }
    klass[0] = klass[0].upcase
    klass = Module.const_get(klass)

    klass.new(stats)
  end

  def read_stats
    @stats = {}

    xlsx = Roo::Spreadsheet.open('robotstats.xlsx')
    xlsx.sheets.each do |sheet|
      @stats[sheet] = {}
      (2..30).to_a.each do |row|
        begin
          data = xlsx.sheet(sheet).row(row)
          action = data.shift.downcase.strip.gsub(/\s+/,"_").to_sym
          @stats[sheet][action] = data.map { |v| v.to_f }
        rescue
          # do nothing
        end
      end
    end
    Simulation.set_stats(@stats)
  end

  def robot_stats(name)
    @stats[name]
  end

  def play
    @stronghold.play
  end

  def results
    @stronghold.results
  end
end

sim = Simulation.new(ARGV.first)
sim.play
sim.results

__END__



blue1 = SiriusV1.new("Sirius")
blue2 = BaseRobot.new("Bot2")
blue3 = BaseRobot.new("Bot3")

red1 = BaseRobot.new("Bot4")
red2 = BaseRobot.new("Bot5")
red3 = BaseRobot.new("Bot6")

s = Stronghold.new
s.blue_alliance(blue1, blue2, blue3)
s.red_alliance(red1, red2, red3)

s.play
s.results

gen = Rubystats::NormalDistribution.new(12.0, 3.0)
lowest = 12.0

__END__
1_000_000.times do 
  val = gen.rng
  lowest = val if val < lowest
end

puts lowest
#pp gen.rng(100)
