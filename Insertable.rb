require 'ostruct'
require 'optparse'

class Insertable

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

  def convert_to_insertable(filename,fields)
  
    count = 0
    
    File.open(filename,'r').each do |line|

      line = format_line(strip_leading_whitespace(line))
  
      key  = line.split(/ : /)[0]
      val  = line.split(/ : /)[1]

      field1 = fields[0] 
      field2 = fields[1]

      @data[count] = {fields: [], values: []} if @data[count].nil?
      [@data.dig(count, :fields), @data.dig(count, :values)].each {|a| a.clear} if key.eql?(field1)
  
      @data.dig(count, :fields).push key.nil? ? String.new : key.chomp
      @data.dig(count, :values).push val.nil? ? String.new : val.chomp

      count += 1 if key.eql?(field2)
      
    end
  end

end

options = OpenStruct.new 
fields_opt_help = 'This is the first and the last field of the table you are querying.'

OptionParser.new do |opt|
  opt.on('--help', TrueClass) {|help| options.help = help }
  opt.on('tTABLE','--table TABLE', String) {|table| options.table = table }
  opt.on('--without-id',TrueClass) {|without_id| options.without_id = without_id}
  opt.on('--fields f1,f2', Array, fields_opt_help) {|fields| options.fields = fields }
  opt.on('-fFILENAME', '--filename FILENAME', String) {|filename| options.filename = filename }
end.parse!

insertable = Insertable.new
criteria   = !(options.filename.nil? || options.fields.nil? || options.help || options.table.nil? || !options.fields.count.eql?(2))

criteria ? insertable.convert_to_insertable(options.filename,options.fields) : insertable.usage

(0..insertable.data.count.to_i).each do |iteration|

  values = insertable.data.dig(iteration, :values)
  fields = insertable.data.dig(iteration, :fields)

  unless [values,fields].any? {|a| a.nil?}

    [values,fields].each {|item| item.delete_at(0) if fields[0].eql?(options.fields[0]) } if options.without_id

    values = values.to_s.gsub(/[\[\]]/,"")
    fields = fields.to_s.gsub(/[\[\]\"]/,"")

    puts "insert into #{options.table} (#{fields}}) values (#{values});"

  end
end
