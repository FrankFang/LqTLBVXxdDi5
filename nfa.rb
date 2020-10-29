class Rule < Struct.new(:source_state, :char, :target_state)
  def applies_to?(state, char)
    self.source_state == state and self.char == char
  end
  def inspect
    "#{source_state} --#{char}-> #{target_state}"
  end
end

class NFARuleList < Struct.new(:rules)
  def find_rules_for(state, char)
    rules.filter { |rule| rule.applies_to?(state, char) }
  end
  def find_targets_for(states, char)
    states.flat_map { |state|
      find_rules_for(state, char).map(&:target_state)
    }.uniq
  end
end

class NFA < Struct.new(:current_states, :accepted_states, :rule_list)
  def is_accepted?
    (accepted_states & current_states).size > 0
  end
  def read_char(char)
    self.current_states = rule_list.find_targets_for(current_states, char)
  end
  def read_string(string)
    string.chars.each { |char| read_char char }
  end
  def accepts?(string)
    read_string(string)
    is_accepted?
  end
end

rules = NFARuleList.new(
  [
    Rule.new(1, 'a', 1),
    Rule.new(1, 'b', 1),
    Rule.new(1, 'b', 2),
    Rule.new(2, 'a', 3),
    Rule.new(2, 'b', 3),
    Rule.new(3, 'a', 4),
    Rule.new(3, 'b', 4)
  ]
)
p rules.find_targets_for([1], 'b')
# [1,2]
p rules.find_targets_for([1, 2], 'a')
# [1,3]
p rules.find_targets_for([1, 3], 'a')
# [1,4]
nfa = NFA.new([1], [4], rules)
p nfa.accepts? 'baa'


