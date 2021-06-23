require 'date'
require 'mysql2'
require 'thread'
require 'ostruct'
require 'optparse'

require './requires.rb'

class Insertable

  attr_accessor :data

  def initialize

    @data     = Hash.new
    @mutex    = Mutex.new

    @host     = EnvConfig.instance.db_host
    @database = EnvConfig.instance.db_database
    @username = EnvConfig.instance.db_username
    @password = EnvConfig.instance.db_password

    @client   = Mysql2::Client.new(
      :host => @host, :username => @username, :password => @password, :database => @database
    )
  end

  def usage(message=nil)

    puts "\n    ** #{message} ** \n" unless message.nil? or message.empty?

    puts "\n\n    Usage example: ruby #{$PROGRAM_NAME} -q'select * from cars limit 10' -tcars --fields make, model --without-id\n"
    puts "\n    [ Option with * is mandatory! ]\n\n"
    puts "      Option:\n        --help,            Display this help messgage.\n"
    puts "    * Option:\n        --table,       -t, The name of the table that you are querying.\n"
    puts "    * Option:\n        --mysql-query, -q, MySQL query for the program to parse without ; or \G terminator.\n"
    puts "      Option:\n        --without-id,      Remove the id field name and the id from the printed insertable.\n"
    puts "    * Option:\n        --fields f1,f2     This is the first and last field of the specified table that you are querying.\n"
    exit
  end

  def remove_timezone_from_date(string)
    begin
      if string.to_s.match(/[-:]/)
        return DateTime.parse(string.to_s).strftime('%Y-%m-%d %H:%M:%S').to_s
      else
        raise ArgumentError
      end
    rescue ArgumentError
      return string
    end
  end

  def mysql_query(query)
    begin
      @mutex.synchronize do 
        results = @client.query(query)
        begin
          return results
        rescue Exception => exception
          puts "Insertable.temp exception(1) => #{exception}"
        end
      end
    rescue Exception => exception
      puts "Insertable.temp exception(2) => #{exception}"
    end
  end

  def print_insertable(insertable_data,options)
    (0..insertable_data.count.to_i).each do |iteration|

      values = insertable_data.dig(iteration, :values)
      fields = insertable_data.dig(iteration, :fields)

      unless [values,fields].any? {|a| a.nil?}

        [values,fields].each {|item| item.delete_at(0) if fields[0].eql?(options.fields[0]) } if options.without_id

        values = values.to_s.gsub(/[\[\]]/,"")
        fields = fields.to_s.gsub(/[\[\]\"]/,"")

        puts "insert into #{options.table} (#{fields}) values (#{values});"

      end
    end
  end

  def format_insertable(query,fields)
  
    count  = 0
    field1 = fields[0] 
    field2 = fields[1]
    
    mysql_query(query).each do |line|

      line.each do |key,val|

        val = remove_timezone_from_date(val)

        @data[count] = {fields: [], values: []} if @data[count].nil?
        [@data.dig(count, :fields), @data.dig(count, :values)].each {|a| a.clear} if key.eql?(field1)
        
        @data.dig(count, :fields).push key.nil? ? String.new : key.to_s
        @data.dig(count, :values).push val.nil? ? String.new : val.to_s

        count += 1 if key.eql?(field2)
      end
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
  opt.on('-qQUERY', '--mysql-query QUERY', String) {|query| options.query = query }
end.parse!

criteria1  = !(options.query.nil? || options.fields.nil?) 
criteria2  = !(options.table.nil? || !options.fields.count.eql?(2))

(criteria1 && criteria2) ?
  (insertable.format_insertable(options.query,options.fields); insertable.print_insertable(insertable.data,options)) : insertable.usage
