# frozen_string_literal: true
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
    @open_comment || @current_line.strip.start_with?('*/') || @current_line.strip.start_with?('*/')
  end

  def trailing_space
    error_message('Trailing space', 'warning')  if @current_line.end_with?(' ')
  end

  def check_block
    check_close_block(check_open_block)
  end

  def check_new_line
    if @closed_block && @current_line.strip.length.positive?
      error_message('Expected empty line', 'warning')
    end

    @closed_block = false
  end

  def remove_comment
    start_index = @current_line.index('/*')
    stop_index = @current_line.index('*/')
    unless start_index.nil?
      first_half = @current_line[0...start_index]
      !stop_index.nil? ? second_half = @current_line[stop_index + 2...@current_line.length] : second_half =  ''
      @current_line = first_half + second_half
    end
  end

  def end_char
    return unless @current_line.strip.length.positive?

    matches = @current_line.scan(/[;{}]/)
    if matches.length > 1 || (matches.length == 1 && !@current_line.strip.end_with?(matches[0]))
      error_message("Expected new line after #{matches[0]}", 'error')
    elsif matches.empty? && !@current_line.strip.end_with?(',')
      error_message('Missing either a ; { or }'.colorize(:blue), 'error')
    end
  end

  def check_indentation
    expect_space = @open_blocks * @indent_size
    current_space = @current_line[/\A */].size
    return unless current_space != expect_space

    error_message("Expected #{expect_space} spaces but got #{current_space}".colorize(:light_blue), 'error')
  end
  
  private

  def error_message(message, severity)
    @errors.push(ErrorFile.new(@current_line_index, message, severity))
  end

  def check_open_block
    return unless @current_line.include?('{')

    check_indentation # check for indentation before opening the block
    @open_blocks += 1
    error_message('Expected space before {', 'warning') unless @current_line.include?(' {')
    true
  end

  def check_close_block(checked)
    return unless @current_line.include?('}')

    @open_blocks.positive? ? @open_blocks -= 1 : error_message('Stray closing }', 'error')
    @closed_block = true
    # check for indentaion after closing the block if  it has not yet been 
    # checked (single line blocks)
    check_indentation unless checked
  end
end
