class Lexer
  def initialize(sourceCode)
    @sourceCode = sourceCode
    @index = -1
  end
  def readChar
    @index += 1
    return @sourceCode[@index]
  end
  def run
    while current = readChar # 等价于 while (current = readChar) != nil
      if current == 'n'
        current = readChar
        if current == 'e'
          current = readChar
          if current == 'w'
            p '有new'
          end
        end
        if current == 'o'
          current = readChar
          if current == 't'
            p '有not'
          end
        end
      end
    end
  end
end

Lexer.new('if not ok; new Error').run