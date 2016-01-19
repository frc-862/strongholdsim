require_relative 'defenses'

Struct.new("AllianceState", :score, :defense_states, :tower_strenth, :challenged, :scaled, :challenge_count, :breached)

class Stronghold
  attr_reader :mode
  attr_accessor :defenses

  def initialize
    @robots = []
    @mode = :auton
    @alliances = {
      red: Struct::AllianceState.new(0, [2] * 5, 8, [false] * 3, [false] * 3, 0, false),
      blue: Struct::AllianceState.new(0, [2] * 5, 8, [false] * 3, [false] * 3, 0, false)
    }
    @defenses = random_defenses
    @clock = 0
  end

  def blue_alliance(r1, r2, r3)
    @blue_alliance = [r1, r2, r3];
  end

  def red_alliance(r1, r2, r3)
    @red_alliance = [r1, r2, r3]
  end

  def score
    @alliance.score
  end

  def defense_states
    @alliance.defense_states
  end

  def each_robot(&block)
    @blue_alliance.each do |robot|
      @alliance = @alliances[:blue]
      @other_alliance = @alliances[:red]
      @robot = robot
      block.call(robot, self)
    end
    @red_alliance.each do |robot|
      @alliance = @alliances[:red]
      @other_alliance = @alliances[:blue]
      @robot = robot
      block.call(robot, self)
    end
  end

  def clock
    @clock
  end

  def play
    150.times do 
      each_robot do |robot|
        robot.internal_auton(self)
      end 
      @clock += 1
    end

    @mode = :teleop
    1150.times do 
      each_robot do |robot|
        robot.internal_tick(self)
      end 
      @clock += 1
    end

    @mode = :end_game
    200.times do 
      each_robot do |robot|
        robot.tick(self)
      end 
      @clock += 1
    end
  end

  def high_goal
    puts "High goal!!! #{auton?} #{@alliance.score}"
    if auton?
      @alliance.score = @alliance.score.to_i + 10
    else
      @alliance.score = @alliance.score.to_i + 5
    end
    @alliance.tower_strenth -= 1 if @alliance.tower_strenth > 0
  end

  def low_goal
    if auton?
      @alliance.score = @alliance.score.to_i + 5
    else
      @alliance.score = @alliance.score.to_i + 2
    end
    @alliance.tower_strenth -= 1 if @alliance.tower_strenth > 0
  end

  def cross_defence(pos)
    puts "Cross defence #{pos}: #{@alliance.defense_states.inspect}"
    if (@alliance.defense_states[pos] -= 1) >= 0
      @alliance.score += auton? ? 10 : 5
    end

    if breached? && !@alliance.breached
      @alliance.score += 20
    end
  end

  def auton?
    @mode == :auton
  end

  def reach_defence(pos)
    if auton?
      @alliance.score += 2
    end
  end

  def challenge(pos = nil)
    if pos.nil? || !@alliance.challenged[pos]
      @alliance.score += 5
      @alliance.challenged[pos] = true if pos
      if (@alliance.challenge_count += 1) >= 3
        if @alliance.tower_strenth <= 0
          @alliance.score += 25
        end
      end
    end
  end

  def foul 
    @other_alliance.score += 5
  end

  def tech_foul 
    @other_alliance.score += 5
    @other_alliance.tower_strenth += 1
  end

  def breached?
    !@alliance.defense_states.find { |v| v > 0 } 
  end

  def scale(pos=nil)
    if pos.nil? || !@alliance.scaled[pos]
      @alliance.score += 10
      @alliance.scaled[pos] = true if pos
    end
  end

  def results
    pp @alliances
  end
end
