require 'ostruct'
require 'optparse'

class MySQLQuery

  attr_accessor :data

  def initialize
    @data = Hash.new
  end

  def usage(message=nil)

    puts "\n    ** #{message} ** \n" unless message.nil? or message.empty?

    puts "\n\n    Usage: #{$PROGRAM_NAME} --file-name=FILENAME or -fFILENAME\n\n"
    puts "    Option:\n        --help,            Display this help messgage.\n\n"
    puts "    Option:\n        --filename, -f,    File for the program to tail.\n"
    exit
  end

  def strip_leading_whitespace(line)
    line.gsub(/^[ \t]*/,"")
  end

  def format_line(line)
    line.gsub(/: /," : ")
  end

  def convert_to_insertable(filename,mode='r')
  
    count = 0
    
    File.open(filename,mode).each do |line|

      line = format_line(strip_leading_whitespace(line))
  
      key  = line.split(/ : /)[0]
      val  = line.split(/ : /)[1]

      @data[count] = {fields: [], values: []} if @data[count].nil?
      [@data.dig(count, :fields), @data.dig(count, :values)].each {|a| a.clear} if key.eql?('id')
  
      @data.dig(count, :fields).push key.nil? ? String.new : key.chomp
      @data.dig(count, :values).push val.nil? ? String.new : val.chomp

      count += 1 if key.eql?('userfield')
      
    end
  end

end

options = OpenStruct.new 

OptionParser.new do |opt|
  opt.on("--help", TrueClass) {|help| options.help = help }
  opt.on('-fFILENAME', '--filename FILENAME', String) {|filename| options.filename = filename }
end.parse!

mysql_query = MySQLQuery.new
      
(options.filename.nil? || options.help) ? mysql_query.usage : mysql_query.convert_to_insertable(options.filename)

puts "#{mysql_query.data[1]}"
