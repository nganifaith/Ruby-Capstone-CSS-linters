# frozen_string_literal: true

# spec/css_linter_spec.rb

require_relative '../lib/error_file.rb'
require_relative '../lib/parser.rb'
require_relative '../lib/read_file.rb'

describe ReadFile do
  it 'should return and error' do
    file = ReadFile.new('./hello')
    expect(file.error_msg).to eql('Check file path')
  end
  it 'should return the content in the file' do
    file = ReadFile.new('././style.css')
    expect(file.content.length.positive?).to eql(true)
  end
end

describe Parser do
  describe '#parse_file' do
    it 'should return all errors in the file' do
      parse_test = Parser.new
      file = ReadFile.new('././style.css')
      parse_test.parse_file(file.content)
      expect(parse_test.errors.length).to eql(16)
    end
    it 'should return and empty array' do
      parse_test = Parser.new
      parse_test.parse_file([])
      expect(parse_test.errors.length).to eql(0)
    end
  end
end
