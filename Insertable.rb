require 'ostruct'
require 'optparse'

class Insertable

  attr_accessor :data

  def initialize
    @data = Hash.new
  end

  def usage(message=nil)

    puts "\n    ** #{message} ** \n" unless message.nil? or message.empty?

    puts "\n\n    Usage example: ruby #{$PROGRAM_NAME} -fquery.txt -tcars --fields make, model --without-id\n"
    puts "\n    [ Option with * is mandatory! ]\n\n"
    puts "      Option:\n        --help,            Display this help messgage.\n"
    puts "    * Option:\n        --table,    -t,    The name of the table that you are querying.\n"
    puts "    * Option:\n        --filename, -f,    File with MySQL query for the program to parse.\n"
    puts "      Option:\n        --without-id,      Remove the id field name and the id from the printed insertable.\n"
    puts "    * Option:\n        --fields f1,f2     This is the first and last field of the specified table that you are querying.\n"
    exit
  end

  def strip_leading_whitespace(line)
    line.gsub(/^[ \t]*/,"")
  end

  def format_line(line)
    line.gsub(/: /," : ")
  end

  def print_insertable(insertable_data,options)
    (0..insertable_data.count.to_i).each do |iteration|

      values = insertable_data.dig(iteration, :values)
      fields = insertable_data.dig(iteration, :fields)

      unless [values,fields].any? {|a| a.nil?}

        [values,fields].each {|item| item.delete_at(0) if fields[0].eql?(options.fields[0]) } if options.without_id

        values = values.to_s.gsub(/[\[\]]/,"")
        fields = fields.to_s.gsub(/[\[\]\"]/,"")

        puts "insert into #{options.table} (#{fields}}) values (#{values});"

      end
    end
  end

  def format_insertable(filename,fields)
  
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

options    = OpenStruct.new 
insertable = Insertable.new

OptionParser.new do |opt|
  opt.on('--help', TrueClass) {|help| insertable.usage }
  opt.on('-tTABLE','--table TABLE', String) {|table| options.table = table }
  opt.on('--without-id',TrueClass) {|without_id| options.without_id = without_id}
  opt.on('--fields f1,f2', Array) {|fields| options.fields = fields }
  opt.on('-fFILENAME', '--filename FILENAME', String) {|filename| options.filename = filename }
end.parse!

criteria1  = !(options.filename.nil? || options.fields.nil?) 
criteria2  = !(options.table.nil? || !options.fields.count.eql?(2))

(criteria1 && criteria2) ?
  (insertable.format_insertable(options.filename,options.fields); insertable.print_insertable(insertable.data,options)) : insertable.usage
