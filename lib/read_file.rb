# frozen_string_literal: true

# This class loads and reads the file into out program

class ReadFile
  attr_reader :file_path, :error_msg, :content
  def initialize(path)
    @file_path = path
    @error_msg = ''
    begin
      File.open(path) do |file|
        @content = file.readlines.map(&:chomp)
      end
    rescue StandardError
      @content = []
      @error_msg = 'Check file path'
    end
  end
end
