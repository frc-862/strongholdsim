DefenseTypes = %i(portcullis cheval_de_frise moat ramparts drawbridge sally_port rock_wall rough_terrain low_bar)

def random_defenses
  defenses = [[:low_bar, nil, nil, nil, nil],[:low_bar, nil, nil, nil, nil]]

  blue_avail = DefenseTypes[0..-2].each_slice(2).to_a.clone
  red_avail = DefenseTypes[0..-2].each_slice(2).to_a.clone

  # select audience defense category
  category = rand(blue_avail.length)

  # select audience defense
  choice = rand(2)
  defenses[0][2] = blue_avail[category][choice]
  defenses[1][2] = red_avail[category][choice]
  blue_avail.delete_at(category)
  red_avail.delete_at(category)

  blue_avail = blue_avail.shuffle
  red_avail = red_avail.shuffle
  [1,3,4].each do |i|
    defenses[0][i] = blue_avail.shift[rand(2)]
    defenses[1][i] = red_avail.shift[rand(2)]
  end

  defenses
end

