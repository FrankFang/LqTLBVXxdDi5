class Rule < Struct.new(:source_state, :char, :target_state)
  def inspect
    "<#{source_state} ---#{char}--> #{target_state}>"
  end
  def applies_to?(state, char)
    self.source_state == state and self.char == char
  end
end
class FARuleList < Struct.new(:rules)
  def find_rule_for(state, char)
    rules.find { |rule| rule.applies_to?(state, char) }
  end
  def find_target_for(state, char)
    find_rule_for(state, char).target_state
  end
end
class FiniteAutomaton < Struct.new(:current_state, :accepted_states, :rule_list)
  def is_accepted?
    accepted_states.include? current_state
  end
  def read_char(char)
    self.current_state = rule_list.find_target_for(current_state, char)
  end
  def read_string(string)
    string.chars.each { |char| read_char char }
  end
  def accepts?(string)
    read_string(string)
    is_accepted?
  end
end

class FAFactory < Struct.new(:start_state, :accepted_states, :rule_list)
  def create_fa
    FiniteAutomaton.new(start_state, accepted_states, rule_list)
  end
  def accepts?(string)
    create_fa.accepts? string
  end
end

r1 = Rule.new(1, 'a', 2)
r2 = Rule.new(2, 'a', 1)
rules = FARuleList.new([r1, r2])
faf = FAFactory.new(1, [2], rules)
p faf.accepts?('a')
p faf.accepts?('aa') 
p faf.accepts?('aaa') 
p faf.accepts?('aaaa') 
p faf.accepts?('aaaaa') 