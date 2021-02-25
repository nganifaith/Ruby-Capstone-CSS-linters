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
    @open_comment = @current_line.include?('/*') unless open_comment
    @open_comment &&= !@current_line.include?('*/')
    @open_comment || @current_line.strip.start_with?('*/') || @current_line.strip.start_with?('*/')
  end

  def trailing_space
    error_message('Trailing space', 'warning')  if @current_line.end_with?(' ')
  end

  def check_block
    @open_blocks += 1 if @current_line.include?('{')
    if @current_line.include?('{') && !@current_line.include?(' {')
      error_message('Expected space before {', 'warning')
    end
    if @current_line.include?('}')
      @open_blocks.positive? ? @open_blocks -= 1 : error_message('Stray closing }','error')
      @closed_block = true
    end
  end

  def check_new_line
    if @closed_block && @current_line.strip.length.positive?
      error_message('Expected empty line', 'warning')
    end

    @closed_block = false
  end

  def remove_comment
    start_index = @current_line.index('/*')
    if start_index.nil?
      @current_line = !@current_line.include?('*/') ? @current_line[0...start_index] : @current_line[0...start_index] + @current_line[@current_line.index('*/') + 2...@current_line.length]
    end
  end

  def end_char
    return unless @current_line.strip.length.positive?

    matches = @current_line.scan(/[;{}]/)
    if matches.length > 1 || (matches.length == 1 && @current_line.strip.index(matches[0]) != @current_line.strip.length - 1)
      error_message("Expected new line after #{matches[0]}", 'error')

    elsif matches.empty? && !@current_line.strip.end_with?(',')
      error_message('Missing either a ; { or }'.colorize(:blue), 'error')
    end
  end

  private

  def error_message(message, severity)
    @errors.push(ErrorFile.new(@current_line_index, message, severity))
  end
end
