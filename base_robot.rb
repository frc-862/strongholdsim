
class BaseRobot
  attr_reader :name
  attr_accessor :state, :location

  def initialize(name)
    @name = name
    @state = :still
    @location = :neutral_zone
    @wait = 0
    puts "Wait is #{@wait} - #{@name}"
    @after_wait = lambda {}
  end

  def check_wait
    #puts "ChkWait is #{@wait} - #{@name}"
    if @wait > 0
      @wait -= 1.0
    else
      @after_wait.call if @after_wait
      @after_wait = nil
      yield
    end
  end

  def internal_tick(game)
    check_wait do
      tick(game)
    end
  end

  def internal_auton(game)
    check_wait do
      auton(game)
    end
  end

  def wait(time)
    @wait = time.to_i
  end
 
  def wait_then(time, &block)
    #puts "wait_then(#{time.to_i.inspect}, #{time.inspect})"
    @after_wait = block
    @wait = time.to_i
  end

  def auton(game)
    #game.high_goal
  end

  def tick(game)
  end
  
  def to_s
   "#{@name}"
  end 
end

