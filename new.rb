class Lexer
  def initialize(sourceCode)
    @sourceCode = sourceCode
    @index = -1
  end
  def readChar # 读取下一个字符
    @index += 1
    return @sourceCode[@index]
  end
  def run
    while current = readChar 
      if current == 'n'
        current = readChar
        if current == 'e'
          current = readChar
          if current == 'w'
            p '有new'
          end
        end
      end
    end

  end
end

Lexer.new('I have a red phone').run