require_relative 'error_file.rb'
# This class implements out css checkers
class Parser
  attr_reader :errors, :open_blocks, :open_comment, :indent_size, :num_selectors
  attr_reader :current_line, :current_line_index, :closed_block

  def initialize
    @errors = []
    @open_blocks = 0
    @open_comment = false
    @closed_block = false
    @indent_size = 2
    @num_selectors = 0
    @current_line_index = 0
    @current_line = ''
  end

  def next_line(line)
    @current_line_index += 1
    @current_line = line
  end

  def check_comment
    @open_comment = @current_line.include?('/*')
    @open_comment &&= !@current_line.include?('*/')
    @open_comment || stripped.start_with?('*/') || stripped.start_with?('*/')
  end

  def trailing_space
    error_message('Trailing space', 'warning')  if @current_line.end_with?(' ')
  end

  def check_block
    check_indentation unless check_close_block(check_open_block)
  end

  def check_new_line
    contain_end = stripped.end_with?('}')
    if @closed_block && stripped.length.positive? && !contain_end
      error_message('Expected empty line', 'warning')
    end
    @closed_block = false
  end

  def remove_comment
    start_index = @current_line.index('/*')
    stop_index = @current_line.index('*/')

    return if start_index.nil?

    first_half = @current_line[0...start_index]

    second_half = ''
    unless stop_index.nil?
      second_half = @current_line[stop_index + 2...@current_line.length]
    end

    @current_line = first_half + second_half
  end

  def end_char
    return unless stripped.length.positive?

    matches = @current_line.scan(/[;{}]/)

    if matches.size.positive?
      return if stripped.end_with?(matches[0])

      error_message("Expected new line after #{matches[0]}", 'warning')
    else
      return if stripped.end_with?(',')

      error_message('Missing either a ; { or }'.colorize(:blue))
    end
  end

  def check_indentation
    return unless stripped.length.positive?

    expect_space = @open_blocks * @indent_size
    current_space = @current_line[/\A */].size
    return unless current_space != expect_space

    error_message("Expected #{expect_space} spaces but got #{current_space}")
  end

  def check_missing_tags
    error_message('Missing }') if open_blocks.positive?
  end

  private

  def error_message(message, severity = 'error')
    @errors.push(ErrorFile.new(@current_line_index, message, severity))
  end

  def check_open_block
    return unless @current_line.include?('{')

    check_indentation # check for indentation before opening the block
    @open_blocks += 1
    return true if @current_line.include?(' {')

    error_message('Expected space before {', 'warning')
    true
  end

  def check_close_block(checked)
    return checked unless @current_line.include?('}')

    error_message('Stray closing }', 'error') unless @open_blocks.positive?
    @open_blocks -= 1 if @open_blocks.positive?
    @closed_block = true
    # check for indentaion after closing the block if  it has not yet been
    # checked (single line blocks)
    check_indentation unless checked
    true
  end

  def stripped
    @current_line.strip
  end
end
