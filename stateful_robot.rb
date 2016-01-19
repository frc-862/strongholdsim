require_relative 'base_robot'
require_relative 'normal_distribution'

class StatefulRobot < BaseRobot

  def initialize(name)
    super
    @stats = Simulation.get_robot_stats(name)
    @state = :start
    @game = nil
  end

  def auton(game)
    state_engine(game)
  end

  def tick(game)
    state_engine(game)
  end

  def state_engine(game)
    @game = game
    if self.respond_to?(@state)
      self.send @state
    end
  end

  def attempt(action, success, failure=:retry)
    puts "#{@game.clock} attempt: #{action}"
    chances = @stats[action]
    if chances.nil?
      raise "Unknown action: #{action}"
    end

    # check for fouls
    if (rand * 100) <= chances[6]
      tech_foul
    elsif (rand * 100) <= chances[5]
      foul
    end

    if (rand * 100) <= chances.first
      mean = chances[1]
      stddev = chances[2]
      puts "success: #{success}"
      wait_then(ND.new(mean, stddev, mean / 3)) do
        @state = success
      end
    else
      mean = chances[3]
      stddev = chances[4]

      if mean.zero?
        mean = chances[1]
        stddev = chances[2]
      end

      puts "failed: #{failure} #{mean} #{stddev}"
      wait_then(ND.new(mean, stddev, mean / 3)) do
        @state = failure if failure != :retry
      end
    end
  end

  def attempt_old(chance, success, failure, success_time, failure_time = success_time)
    if (rand * 100) <= chance.to_f
      wait_then(success_time) do
        puts "Success, switching to #{success} - #{@game.score} - #{@game.defense_states.inspect}"
        @state = success
      end
    else
      wait_then(failure_time) do
        puts "Failed, switching to #{failure} - #{@game.score} - #{@game.defense_states.inspect}"
        @state = failure if failure != :retry
      end
    end
  end

  def method_missing(meth, *args, &block)
    if @game.respond_to?(meth)
      @game.send(meth, *args, &block)
    else
      super
    end
  end

end
