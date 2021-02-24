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
end