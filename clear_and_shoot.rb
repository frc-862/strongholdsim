require_relative 'stateful_robot'

class ClearAndShoot < StatefulRobot
  def initialize(name)
    super(name)
    @state = :do_nothing
  end

  def do_nothing
  end
end

