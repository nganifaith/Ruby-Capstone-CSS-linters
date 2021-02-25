# frozen_string_literal: true

require 'colorize'
require 'colorized_string'
# This class creates and an array of errors seen
class ErrorFile
  attr_reader :line, :error, :severity
  def initialize(line, error, severity)
    @line = line
    @error = error
    @severity = severity
  end

  def color_severity
    case @severity
    when 'warning' then @severity.colorize(:yellow)
    when 'error' then @severity.colorize(:red)
    else
      @severity.colorize(:light_blue)
    end
  end
end
