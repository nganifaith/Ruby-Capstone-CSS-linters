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
    @severity == 'warning' ? @severity.colorize(:yellow) : @severity.colorize(:red)
  end
end
