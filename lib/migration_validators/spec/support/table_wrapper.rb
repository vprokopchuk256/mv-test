module MigrationValidators
  module Spec
    module Support
      class TableWrapper
        attr_accessor :table_name

        def initialize table_name, db
          @table_name = table_name
          @db = db
        end

        def drop
          @db.drop_table(table_name) if @db.table_exists?(table_name)
        end

        alias_method :old_method_missing, :method_missing
        def method_missing method_name, *args
          return MigrationValidators::Spec::Support::ColumnWrapper.new(method_name, self, @db) if @db.column_exists?(table_name, method_name)

          old_method_missing method_name, *args
        end
      end
    end
  end
end
