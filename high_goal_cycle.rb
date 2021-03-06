require_relative 'stateful_robot'

class HighGoalCycle < StatefulRobot

  def initialize(name)
    super(name)
    puts "New robot"
    @state = :cross_outerworks
  end

  def attempt_high_goal
    attempt(:shoot_high_goal_far, :shot_high_goal, :retrieve_boulder_in_courtyard)
  end

  def retry_low_bar
    attempt(:return_low_bar, :retrieve_boulder_from_neutral_zone)
  end

  def shot_high_goal
    high_goal
    attempt(:return_low_bar, :retrieve_boulder_from_neutral_zone, :retry_low_bar)
  end

  def retrieve_boulder_in_courtyard
    attempt(:retrieve_boulder_in_courtyard, :attempt_high_goal)
  end

  def cross_outerworks
    @d = get_defense_states.find_index { |e| e > 0 }.to_i
    puts "cross: #{cross_name(@d)}"
    attempt(cross_name(@d), :crossed_outerworks)
  end

  def crossed_outerworks
    cross_defence(@d.to_i)
    attempt(:shoot_high_goal_far, :shot_high_goal, :retrieve_boulder_in_courtyard)
  end

  def retrieve_boulder_from_neutral_zone
    attempt(:retrieve_boulder_from_neutral_zone, :cross_outerworks)
  end

end
