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
  def find_free_targets_for(states)
    target_states = find_targets_for(states, nil)
    # 如果得到的状态是源状态的子集或等价集合
    # 说明已经找不到更多状态了
    if target_states & states == target_states
    # &用来求交集，比如 [2,4] & [1] 结果为 []
    # &用来求交集，比如 [1] & [1,2,4] 结果为 [1]
    # &用来求交集，比如 [1,2,4] & [1,2,4] 结果为 [1,2,4]
      states
    else
      find_free_targets_for(states + target_states)
    end
  end
end

class NFA < Struct.new(:current_states, :accepted_states, :rule_list)
  def is_accepted?
    (accepted_states & current_states).size > 0
  end
  def read_char(char)
    self.current_states = rule_list.find_free_targets_for(current_states)
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

class NFAFactory < Struct.new(:start_state, :accepted_states, :rule_list)
  def create_nfa
    NFA.new([start_state], accepted_states, rule_list)
  end
  def accepts?(string)
    create_nfa.accepts? string
  end
end

rules = NFARuleList.new(
  [
    Rule.new(1, nil, 2),
    Rule.new(1, nil, 4),
    Rule.new(2, 'a', 3),
    Rule.new(3, 'a', 2),
    Rule.new(4, 'a', 5),
    Rule.new(5, 'a', 6),
    Rule.new(6, 'a', 4),
  ]
)

factory = NFAFactory.new(1, [2,4], rules)
p factory.accepts? 'aa'
p factory.accepts? 'aaa'
p factory.accepts? 'aaaaa'
p 'nfa_2.rb 运行完毕'