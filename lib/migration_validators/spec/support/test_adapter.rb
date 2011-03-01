module MigrationValidators
  module Spec
    module Support
      class TestAdapter
        def name 
          "TestAdapter"
        end

        class << self
          def stub_method method_name_prefix, validator_name, db_form
            method_name_suffix = db_form ? "_#{db_form}" : ""
            method_name = :"#{method_name_prefix}_#{validator_name}#{method_name_suffix}"

            define_method method_name do |validators|
              TestAdapter.call(method_name, validators)
              yield(validators) if block_given?
            end
          end
          private :stub_method

          def stub_validate_method validator_name, db_form = nil, &block
            stub_method :validate, validator_name, db_form, &block
          end

          def stub_remove_validate_method validator_name, db_form = nil, &block
            stub_method :remove_validate, validator_name, db_form, &block
          end

          def log
            @log ||= {}
          end

          def clear 
            @log = nil

            public_instance_methods.grep(/^validate_/) { |method_name| undef_method method_name }
            public_instance_methods.grep(/^remove_validate_/) { |method_name| undef_method method_name }
          end

          def call method_name, validators
            (log[method_name] ||= []) << validators
          end
        end
      end
    end
  end
end
