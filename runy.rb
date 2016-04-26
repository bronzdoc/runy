# Token types
#
# EOF (end-of-file) token is used to indicate that
# there is no more input left for lexical analysis
INTEGER, PLUS, EOF = 'INTEGER', 'PLUS', 'EOF'

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

class Interpreter
  def initialize(text)
    # client string input, e.g. "3+5"
    @text = text

    # @pos is an index into @text
    @pos = 0

    # current token instance
    @current_token = nil
  end

  def error
    raise 'Error parsing input'
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
      @pos += 1
      return Token.new(INTEGER, current_char.to_i)
    end

    if current_char == '+'
      @pos += 1
      return Token.new(PLUS, current_char)
    end

    error
  end

  def eat(token_type)
    # compare the current token type with the passed token
    # type and if they match then "eat" the current token
    # and assign the next token to the @current_token,
    # otherwise raise an exception.

    if @current_token.type == token_type
      @current_token = get_next_token
    else
      error
    end
  end

  def expr
    # expr -> INTEGER PLUS INTEGER
    # set current token to the first token taken from the input
    @current_token = get_next_token

    # we expect the current token to be a single-digit integer
    left = @current_token
    eat(INTEGER)

    # we expect the current token to be a '+' token
    op = @current_token
    eat(PLUS)

    # we expect the current token to be a single-digit integer
    right = @current_token
    eat(INTEGER)
    # after the above call the @current_token is set to
    # EOF token

    # at this point INTEGER PLUS INTEGER sequence of tokens
    # has been successfully found and the method can just
    # return the result of adding two integers, thus
    # effectively interpreting client input
    left.value + right.value
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
    result = interpreter.expr
    print(result, "\n")
  end
end
main
