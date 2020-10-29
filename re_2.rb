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
end

re = Repeat.new(
  Choose.new(
    Concat.new(Literal.new('a'), Literal.new('b')),
    Literal.new('a')
  )
)
p re