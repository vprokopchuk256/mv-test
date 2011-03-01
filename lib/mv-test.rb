require 'active_support'
require 'active_record'

require File.expand_path(File.dirname(__FILE__)) + '/migration_validators/spec/support/test_adapter'
require File.expand_path(File.dirname(__FILE__)) + '/migration_validators/spec/support/column_wrapper'
require File.expand_path(File.dirname(__FILE__)) + '/migration_validators/spec/support/table_wrapper'
require File.expand_path(File.dirname(__FILE__)) + '/migration_validators/spec/support/db'
require File.expand_path(File.dirname(__FILE__)) + '/migration_validators/spec/matchers/db_matchers'
require File.expand_path(File.dirname(__FILE__)) + '/migration_validators/spec/macros/db_macros'

RSpec.configure do |config|
  config.include(MigrationValidators::Spec::Support::DB, :type => :mv_test)
  config.include(MigrationValidators::Spec::Matchers::DBMatchers, :type => :mv_test)
  config.include(MigrationValidators::Spec::Macros::DBMacros, :type => :mv_test)
end
