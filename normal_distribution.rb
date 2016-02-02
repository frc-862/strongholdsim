require 'rubystats'

class ND
  def initialize(mean, stddev, min=0)
    @min = min.to_f
    stddev = 0.1 if stddev.zero?
    @gen = Rubystats::NormalDistribution.new(mean.to_f, stddev.to_f)
  end

  def to_i
    result = @gen.rng 
    while result < @min
      result = @gen.rng
    end
    (result * 10).to_i
  end

end
