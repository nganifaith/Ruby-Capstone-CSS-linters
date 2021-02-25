require_relative 'error_file.rb'


class Parser
  attr_reader :errors, :open_blocks, :open_comment, :indent_size, :num_selectors
  def initialize
    @errors = []
    @open_blocks = 0
    @open_comment = false
    @indent_size = 2
    @num_selectors = 0
  end

  def check_comment(line, line_ind)
    unless open_comment
      @open_comment = line.include?("/*")
    end
    @open_comment = @open_comment && !line.include?("*/")
    @open_comment || line.strip.start_with?("/*")
  end

  def trailing_space(line, line_ind)
    @errors.push(ErrorFile.new(line_ind, 'Trailing space', 'warning'))  if line.end_with?(" ")
  end

  def check_block(line, line_ind)
    @open_blocks += 1 if line.include?("{")
    @errors.push(ErrorFile.new(line_ind, 'Expected space before {', 'warning')) if line.include?('{') && !line.include?(' {')
    if line.include?('}')
      @open_blocks.positive? ? @open_blocks -= 1 : @errors.push(ErrorFile.new(line_ind, 'Stray closing }', 'error'))
    end
  end
end