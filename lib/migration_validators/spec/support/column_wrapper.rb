require File.expand_path(File.dirname(__FILE__) + '/db.rb')

module MigrationValidators
  module Spec
    module Support
      class ColumnWrapper
        attr_accessor :column_name
        attr_accessor :last_exception

        def initialize column_name, table_wrapper, db
          @column_name = column_name
          @table_wrapper = table_wrapper
          @db = db
        end

        def drop 
          @db.remove_column @table_wrapper.table_name, column_name
        end

        def update *values
          @last_exception = nil
          ColumnWrapper.to_array(values).each{|value| execute(value, "UPDATE #{@table_wrapper.table_name} SET #{column_name} = #{value}")}
          self
        end

        def insert *values
          @last_exception = nil
          ColumnWrapper.to_array(values).each {|value| execute(value, "INSERT INTO #{@table_wrapper.table_name}(#{column_name}) VALUES(#{value})")}
          self
        end

        def self.to_array values
          values.collect do |value|
            case value.class.name
              when "Range" then to_array(value.to_a)
              when "Array" then to_array(value)
              when "String" then ['NULL', "''"].include?(value.upcase) ? value : quote(value)
              when "Date" then quote(value.strftime('%Y-%m-%d'))
              when "Time" then quote(value.strftime('%Y-%m-%d %H:%M:%S'))
              when "DateTime" then quote(value.strftime('%Y-%m-%d %H:%M:%S'))
              when "NilClass" then 'NULL'
              else value
            end
          end.flatten
        end

        private 

        def self.quote value
          value = "'#{value}" unless value.starts_with?("'")
          value = "#{value}'" unless value.ends_with?("'")
          value
        end


        def execute value, statement
          @last_exception = nil

          begin
            @db.execute(statement) 
          rescue Exception => e 
            @last_exception = e
          end
        end
      end
    end
  end
end
