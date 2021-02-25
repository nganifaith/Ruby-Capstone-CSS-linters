require_relative 'error_file.rb'


class Parser
  attr_reader :errors, :open_blocks, :open_comment, :indent_size, :num_selectors, :current_line, :current_line_index
  def initialize
    @errors = []
    @open_blocks = 0
    @open_comment = false
    @indent_size = 2
    @num_selectors = 0
    @current_line_index = 1
    @current_line = ''
  end

  def check_comment
    unless open_comment
      @open_comment = @current_line.include?("/*")
    end
    @open_comment = @open_comment && !@current_line.include?("*/")
    @open_comment || @current_line.strip.start_with?("/*")
  end

  def trailing_space
    error_message('Trailing space', 'warning')  if @current_line.end_with?(" ")
  end

  def check_block
    @open_blocks += 1 if @current_line.include?("{")
    error_message('Expected space before {', 'warning') if @current_line.include?('{') && !@current_line.include?(' {')
    if @current_line.include?('}')
      @open_blocks.positive? ? @open_blocks -= 1 : error_message('Stray closing }', 'error')
    end
  end

  def next_line(line) 
    @current_line_index += 1
    @current_line = line
  end

  private
  
  def error_message(message, serverity)
    @errors.push(ErrorFile.new(@current_line_index, message, serverity))
  end

end