module MigrationValidators
  module Spec
    module Macros
      module DBMacros
        def self.included(base)
          base.extend(ClassMethods)
        end

        module ClassMethods
          def for_table table_name, &block
            describe "for table #{table_name}" do
              before :all do
                @table_wrapper = table(table_name)
              end

              before :each do
                @table_wrapper.drop
              end

              instance_eval(&block)
            end
          end

          def for_test_table &block
            for_table :test_table, &block
          end

          def for_column column_name, column_type, column_options = {}, &block
            describe "for column #{column_name} (#{column_type})" do
              before :all do
                raise "'for_column' must be called in table context only" unless @table_wrapper.kind_of?(MigrationValidators::Spec::Support::TableWrapper)

                @column_wrapper = MigrationValidators::Spec::Support::ColumnWrapper.new(column_name, @table_wrapper, db)
                @column_type = column_type
                @column_options ||= column_options
              end

              subject do
                @column_wrapper
              end

              before :each do
                new_table @table_wrapper.table_name do |t|
                  t.column @column_wrapper.column_name, @column_type, @column_options.clone
                end
              end
              

              instance_eval(&block)
            end
          end

          def for_test_column column_type, column_options = {}, &block
            for_column :test_column, column_type, column_options, &block
          end

          %w(integer decimal float string date datetime time).each do |type|
            define_method :"for_#{type}_column" do |*args, &block|
              options = args.first || {}

              for_test_column type, options, &block
            end
          end


          def with_validator validator_name, opts = true, &block
            describe "validated for #{validator_name}" do
              before :all do
                raise "'for_validator' must be called in column context only" unless @column_wrapper.kind_of?(MigrationValidators::Spec::Support::ColumnWrapper)

                @validator_name = validator_name
                @column_options.merge!(:validates => {validator_name => opts})
              end
            
              subject do
                @column_wrapper
              end

              instance_eval(&block)
            end
          end

          def with_options opts = {}, &block
            describe "with options #{opts}" do
              before :all do
                raise "'with_options' must be called in validator context only" if @validator_name.blank?

                @column_options = @column_options.clone
                @column_options[:validates] = @column_options[:validates].clone
                validator_options = @column_options[:validates][@validator_name]

             
                @column_options[:validates][@validator_name] = validator_options.kind_of?(Hash) ? validator_options.merge(opts) : opts
              end
            

              subject do
                @column_wrapper
              end

              instance_eval(&block)
            end
          end
          alias_method :with_option, :with_options

          def with_change opts = {}, &block
            describe "with change in column #{opts}" do
              before :all do
                raise "'with_change' must be called in column context only" unless @column_wrapper.kind_of?(MigrationValidators::Spec::Support::ColumnWrapper)
              end

              before :each do
                validation_options = @column_options[:validates]
                validation_options = {} unless validation_options.kind_of?(Hash)
                validation_options.merge!(opts)

                chg_table @table_wrapper.table_name do |t|
                  t.change_validates @column_wrapper.column_name, validation_options
                end
              end

              subject do
                @column_wrapper
              end

              instance_eval(&block)
            end
          end
        end
      end
    end
  end
end
