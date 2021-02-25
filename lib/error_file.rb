class ErrorFile
  attr_reader :line, :error, :severity
  def initialize(line, error, severity)
    @line = line
    @error = error
    @severity = severity
  end
end