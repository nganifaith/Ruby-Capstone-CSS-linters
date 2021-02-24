class ReadFile
  attr_reader :file_path, :error_msg, :content
  def initialize(path)
      @file_path = path
      @error_msg = ''
      begin
        File.open(path) do |file|
          @content = file.readlines
        end
      rescue => exception
        @content = []
        @error_msg = "Check file path"
      end
  end
end
