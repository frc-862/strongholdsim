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

  def goto(state)
    @state = state
  end

  def select_reasonable_defense
    odds_to_cross = @game.defense_names.each_with_index.
        map { |n, index| [@stats["cross_#{n}".to_sym].first, get_defense_states[index], n] }.
        sort_by {|odds, count, name| [-odds, count] }

    # check for an un-weakened defense that we have >= 50% chance of crossing
    result = odds_to_cross.find { |odds, count, name| odds >= 50 && count > 0 }

    if result.nil?
      result = odds_to_cross.first
    else
      result = result
    end
    # puts result.inspect
    # puts odds_to_cross.inspect

    if result
      @game.defense_names.find_index { |n| n == result.last }
    else
      nil
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

  def cross_name(index)
    puts defense_names
    name = defense_names[index]
    name = "cross_#{name}".to_sym
  end

  def return_name(index)
    name = defense_names[index]
    name = "return_#{name}".to_sym
  end

  def method_missing(meth, *args, &block)
    if @game.respond_to?(meth)
      @game.send(meth, *args, &block)
    else
      super
    end
  end

end
