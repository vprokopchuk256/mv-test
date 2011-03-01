module MigrationValidators
  module Spec
    module Support
      module DB
        def use_db config
          ::ActiveRecord::Base.remove_connection if ::ActiveRecord::Base.connected?
          ::ActiveRecord::Base.establish_connection config
        end

        def use_memory_db
          use_db :adapter => "sqlite3", :database => ":memory:"
        end

        def db
          ::ActiveRecord::Base.connection 
        end

        def migrate &block
          migration_class = Class.new(::ActiveRecord::Migration) do
            def self.up
              up_migrate 
            end
          end

          migration_class.class.instance_eval  do
            define_method :up_migrate, &block
          end

          migration_class.migrate(:up)
        end

        def new_table table_name = :test_table, &block
          migrate do
            create_table(table_name) do |t|
              yield t
            end
          end

          table(table_name)
        end

        def chg_table table_name = :test_table, &block
          migrate do
            change_table(table_name) do |t|
              yield t
            end
          end

          table(table_name)
        end

        def table table_name
          MigrationValidators::Spec::Support::TableWrapper.new(table_name, db)
        end
      end
    end
  end
end
