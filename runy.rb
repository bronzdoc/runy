# Token types
#
# EOF (end-of-file) token is used to indicate that
# there is no more input left for lexical analysis
INTEGER, PLUS, MINUS, MULT, DIV, EOF = %w(
  INTEGER
  PLUS
  MINUS
  MULT
  DIV
  EOF
)

class String
  def is_numeric?
     /\A(\+|-)?[0-9]+$/ =~ self
  end
end

class Token
  attr_accessor :type, :value
  def initialize(type, value)
    # token type: INTEGER, PLUS, or EOF
    @type = type

    # token value: 0, 1, 2. 3, 4, 5, 6, 7, 8, 9, '+', or nil
    @value = value
  end

  def to_s
    # String representation of the class instance.
    # Examples:
    #    Token(INTEGER, 3)
    #    Token(PLUS '+')

    "Token(#{@type}, #{@value})"
  end
end

class Lexer
  def initialize(text)
    # client string input, e.g. "3+5"
    @text = text

    # @pos is an index into @text
    @pos = 0
  end

  def get_next_token
    # Lexical analyzer (also known as scanner or tokenizer)

    # This method is responsible for breaking a sentence
    # apart into tokens. One token at a time.
    text = @text

    # is @pos index past the end of the @text ?
    # if so, then return EOF token because there is no more
    # input left to convert into tokens
    if @pos > (text.size - 1) || text[@pos] == "\n"
      return Token.new(EOF, nil)
    end

    # get a character at the position @pos and decide
    # what token to create based on the single character
    current_char = text[@pos]

    # if the character is a digit then convert it to
    # integer, create an INTEGER token, increment @pos
    # index to point to the next character after the digit,
    # and return the INTEGER token
    if current_char.is_numeric?
      int = ""
      # Tokenize multiple digit numbers
      while current_char.is_numeric?
        int << current_char
        @pos += 1
        current_char = text[@pos]
      end
      return Token.new(INTEGER, int.to_i)
    end

    if current_char == "+"
      @pos += 1
      return Token.new(PLUS, current_char)
    end

    if current_char == "-"
      @pos += 1
      return Token.new(MINUS, current_char)
    end

    if current_char == "*"
      @pos += 1
      return Token.new(MULT, current_char)
    end

    if current_char == "/"
      @pos += 1
      return Token.new(DIV, current_char)
    end

    # Ignore whitespace
    if current_char == " "
      @pos += 1
      return get_next_token
    end

    error
  end

  def error
    raise "Syntax Error"
  end
end

class Interpreter
  def initialize(text)
    @lexer = Lexer.new(text)
    @current_token = nil
  end

  def error
    raise 'Error parsing input'
  end

  def factor
    eat(INTEGER)
  end

  def expr
    # expr -> INTEGER PLUS INTEGER
    # set current token to the first token taken from the input
    @current_token = @lexer.get_next_token

    # First token must be an INTEGER token
    result = @current_token.value
    factor
    while [PLUS, MINUS, MULT, DIV].include?(@current_token.type) do
      token = @current_token
      case token.type
      when PLUS
        eat(PLUS)
        result += @current_token.value
        factor
      when MINUS
        eat(MINUS)
        result -= @current_token.value
        factor
      when MULT
        eat(MULT)
        result *= @current_token.value
        factor
      when DIV
        eat(DIV)
        result = result / @current_token.value
        factor
      end
    end

    result
  end

  def eat(token_type)
    # compare the current token type with the passed token
    # type and if they match then "eat" the current token
    # and assign the next token to the @current_token,
    # otherwise raise an exception.

    if @current_token.type == token_type
      @current_token = @lexer.get_next_token
    else
      error
    end
  end

  def run!
    expr
  end
end

def main
  while true
    begin
      print 'calc> '
      text = gets
    rescue EOFError
      break
    end

    next unless text

    interpreter = Interpreter.new(text)
    result = interpreter.run!
    print(result, "\n")
  end
end
main
