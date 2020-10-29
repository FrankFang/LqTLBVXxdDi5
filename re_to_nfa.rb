require './nfa_2.rb'

class Empty
  def to_s
    ''
  end
  def inspect
    "/#{self}/"
  end
  def precedence
    3
  end
  def to_nfa_factory
    start_state = Object.new # 随便创建一个开始状态
    accepted_state = start_state # 初始状态和结束状态相同
    rules = NFARuleList.new([]) # 不读入什么字符
    NFAFactory.new(start_state, [accepted_state], rules)
  end
end

class Literal < Struct.new(:char)
  def to_s
    char
  end
  def inspect
    "/#{self}/"
  end
  def precedence
    3
  end
  def to_nfa_factory
    start_state = Object.new # 随便创建一个开始状态
    accepted_state = Object.new # 随便创建一个结束状态
    rule = Rule.new(start_state, char, accepted_state)
    rules = NFARuleList.new([rule])
    NFAFactory.new(start_state, [accepted_state], rules)
  end
end

class Repeat < Struct.new(:expression)
  def to_s
    e = expression
    "#{e.precedence < self.precedence ? "(#{e})" : e}*"
  end
  def inspect
    "/#{self}/"
  end
  def precedence
    2
  end
  def to_nfa_factory
    expression_nfa = expression.to_nfa_factory
    start_state = Object.new
    accept_states = expression_nfa.accepted_states + [start_state]
    rules = expression_nfa.rule_list.rules
    extra_rules = expression_nfa.accepted_states.map { |accept_state|
      Rule.new(accept_state, nil, expression_nfa.start_state)
    } + [Rule.new(start_state, nil, expression_nfa.start_state)]
    rule_list = NFARuleList.new(rules + extra_rules)
    NFAFactory.new(start_state, accept_states, rule_list)
  end
end

class Choose < Struct.new(:first, :second)
  def to_s
    [first, second]
      .map { |e| e.precedence < self.precedence ? "(#{e})" : e }
      .join('|')
  end
  def inspect
    "/#{self}/"
  end
  def precedence
    0
  end
  def to_nfa_factory
    first_nfa = first.to_nfa_factory
    second_nfa = second.to_nfa_factory
    start_state = Object.new
    accepted_states = first_nfa.accepted_states + second_nfa.accepted_states
    rules = first_nfa.rule_list.rules + second_nfa.rule_list.rules
    extra_rules = [first_nfa, second_nfa].map { |f|
      Rule.new(start_state, nil, f.start_state)
    }
    rule_list = NFARuleList.new(rules + extra_rules)
    NFAFactory.new(start_state, accepted_states, rule_list)
  end
end

class Concat < Struct.new(:first, :second)
  def to_s
    [first, second]
      .map { |e| e.precedence < self.precedence ? "(#{e})" : e }
      .join
  end
  def inspect
    "/#{self}/"
  end
  def precedence
    1
  end
  def to_nfa_factory
    first_nfa = first.to_nfa_factory
    second_nfa = second.to_nfa_factory
    start_state = first_nfa.start_state
    accept_states = second_nfa.accepted_states
    rules = first_nfa.rule_list.rules + second_nfa.rule_list.rules
    extra_rules = first_nfa.accepted_states.map { |state|
      Rule.new(state, nil, second_nfa.start_state)
    }
    rule_list = NFARuleList.new(rules + extra_rules)
    NFAFactory.new(start_state, accept_states, rule_list)
  end
end

nfa_1 = Empty.new.to_nfa_factory
p nfa_1.accepts?('') # true
p nfa_1.accepts?('a') # false
nfa_2 = Literal.new('a').to_nfa_factory
p nfa_2.accepts?('a') # true
p nfa_2.accepts?('b') # false
nfa_3 = Concat.new(Literal.new('a'), Literal.new('b')).to_nfa_factory
p nfa_3.accepts?('ab') # true
p nfa_3.accepts?('ba') # false
p nfa_3.accepts?('bab') # false
nfa_4 = Choose.new(Literal.new('a'), Literal.new('b')).to_nfa_factory
p nfa_4.accepts?('a')
p nfa_4.accepts?('b')
p nfa_4.accepts?('ab')
nfa_5 = Repeat.new(Literal.new('a')).to_nfa_factory
p nfa_5.accepts?('')
p nfa_5.accepts?('a')
p nfa_5.accepts?('ab')
p nfa_5.accepts?('aa')
re = Repeat.new(
  Concat.new(
    Literal.new('a'),
    Choose.new(
      Empty.new, Literal.new('b'))))
p re
p re.to_nfa_factory.accepts? ''
p re.to_nfa_factory.accepts? 'a'
p re.to_nfa_factory.accepts? 'ab'
p re.to_nfa_factory.accepts? 'aba'
p re.to_nfa_factory.accepts? 'abab'
