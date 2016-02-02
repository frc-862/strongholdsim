require_relative 'stateful_robot'

class Knight < StatefulRobot
  def initialize(name)
      super(name)
      @state = :cross_outerworks
  end

  def challenge_tower
    attempt(:challenge_tower,:tower_challenged)
  end

  def tower_challenged
    challenged
    attempt(:scale_tower,:tower_scaled)
  end

  def tower_scaled
    scale
    goto(:done)
  end

  def done

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
    @g = get_defense_states.find_index { |e| e > 0 }.to_i
    if (@game.clock>1300)
      attempt(:challenge_tower, :tower_challenged)
    else
      attempt(:return_low_bar,:cross_outerworks)
    end
  end

  def crossed_outerworks
    cross_defence(@g.to_i)
    attempt(:shoot_high_goal_far, :shot_high_goal, :retrieve_boulder_in_courtyard)
  end

  def retrieve_boulder_from_neutral_zone
    attempt(:retrieve_boulder_from_neutral_zone, :cross_outerworks)
  end
end