module MigrationValidators
  module Spec
    module Matchers
      module DBMatchers
        class BaseDbMatcher
          def initialize *values
            update_and_insert *values
            @all = true
          end

          def initial *values
            @initial = values
            self
          end
          alias_method :from_initial, :initial
          alias_method :with_initial, :initial

          def update *values
            @values = values.flatten
            @update = true
            @insert = false
            self
          end

          def insert *values
            @values = values.flatten
            @update = false
            @insert = true
            self
          end

          def from *values
            @values = values.flatten
            self
          end

          def update?
            @update
          end


          def insert?
            @insert
          end

          def all *values
            @values = values.flatten
            @all = true
            self
          end
          alias_method :for_all_from, :all
          alias_method :for_all, :all

          def at_least_one *values
            @values = values.flatten
            @all = false
            self
          end
          alias_method :for_at_least_one_from, :at_least_one
          alias_method :for_at_least_one, :at_least_one


          def all?
            @all
          end

          def at_least_one?
            !all?
          end

          def values
            @values
          end

          def update_and_insert *values
            @values = values.flatten
            @update = true
            @insert = true
            self
          end
          alias_method :insert_and_update, :update_and_insert


          def operations_array
            res = []

            res << :update if update?
            res << :insert if insert?

            res
          end

          def with_message message
            @message = message
            self
          end
          alias_method :and_message, :with_message

          def message
            @message || ""
          end

          def matches? column_wrapper
            column_wrapper.insert(@initial) if @initial
            
            MigrationValidators::Spec::Support::ColumnWrapper.to_array(values).each do |value|
              passed = true

              if insert?
                column_wrapper.insert value
                passed = check_result(value, column_wrapper.last_exception, :insert)
              end

              if update? && passed
                column_wrapper.update value
                passed = check_result(value, column_wrapper.last_exception, :update)
              end

              return false if all? && !passed
              return true if passed && at_least_one?
            end

            all?
          end 


          protected

          attr_reader :last_operation
          attr_reader :last_value
          attr_reader :last_exception

          def check_result value, exception, operation
            @last_operation = operation
            @last_value = value
            @last_exception = exception

            true
          end

          def compose_message &block
        
            operations_name = operations_array.join(' and operation ')
            elements_name = all? ? 'all_elements' : 'at least one element'
            last_message = last_exception ? "'#{last_exception.message}'" : ""
            expected_message = message.blank? ?  "" : "with message '#{message.kind_of?(Regexp) ?  message.source : message.inspect  }'"

            yield operations_name, elements_name, last_message, expected_message
          end
        end

        class Deny < BaseDbMatcher
          def check_result value, exception, operation
            super && exception && exception.message =~ /#{message}/
          end

          def description
            compose_message do |operations_name, elements_name, last_message, expected_message|
             "expected that operation #{operations_name} would fail for #{elements_name} from #{values} #{expected_message}"
            end
          end


          def failure_message
            compose_message do |operations_name, elements_name, last_message, expected_message|
             "expected that operation #{operations_name} would fail for #{elements_name} from #{values} #{expected_message}. But #{last_operation} #{last_message.blank? ? 'successed with ' : 'raised ' + last_message + ' for '}'#{last_value}'"
            end
          end

          def failure_message_when_negated
            compose_message do |operations_name, elements_name, last_message, expected_message|
             "not expected that operation #{operations_name} would fail for #{elements_name} from #{values} #{expected_message}. But it happened with #{last_operation} on '#{last_value}'"
            end
          end
        end


        class Allow < BaseDbMatcher
          def check_result value, exception, operation
            super && exception.blank?
          end

          def description
            compose_message do |operations_name, elements_name, last_message, expected_message|
             "expected that operation #{operations_name} would success for #{elements_name} from #{values}"
            end
          end

          def failure_message
            compose_message do |operations_name, elements_name, last_message, expected_message|
             "expected that operation #{operations_name} would success for #{elements_name} from #{values}. But #{last_operation} raised #{last_message} for '#{last_value}'"
            end
          end

          def failure_message_when_negated
            compose_message do |operations_name, elements_name, last_message, expected_message|
             "not expected that operation #{operations_name} would success for #{elements_name} from #{values}. But it happened with #{last_operation} on '#{last_value}'"
            end
          end
       end

        def allow *values
          Allow.new *values
        end

        def deny *values
          Deny.new *values
        end
      end
    end
  end
end
