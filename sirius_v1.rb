require_relative 'stateful_robot'

class SiriusV1 < StatefulRobot

  def initialize(name="Sirius")
    super(name)
    @state = :move_to_outerworks
  end

  def move_to_outerworks

    attempt(95, :reach_outerworks, :retry, ND.new(20, 5, 10)) 
  end

  def reach_outerworks
    reach_defence(0)
    attempt(90, :complete_crossing_to_courtyard, :retry, ND.new(60, 10, 30))
  end

  def complete_crossing_to_courtyard
    cross_defence(0)
    attempt(80, :make_high_goal, :retrieve_boulder, ND.new(40, 10, 20))
  end

  def make_high_goal
    high_goal
    attempt(95, :return_to_outerworks, :retry, ND.new(20, 5, 10))
  end

  def retrieve_boulder
    attempt(80, :make_high_goal, :retry, ND.new(40, 10, 20))
  end

  def return_to_outerworks
    attempt(90, :complete_crossing_to_neutral_zone, :retry, ND.new(60, 10, 10))
  end

  def complete_crossing_to_neutral_zone
    attempt(90, :neutral_zone_boulder_aquire, :retry, ND.new(60, 30, 10))
  end

  def neutral_zone_boulder_aquire
    attempt(95, :reach_outerworks, :retry, ND.new(20, 5, 10)) 
  end
end
