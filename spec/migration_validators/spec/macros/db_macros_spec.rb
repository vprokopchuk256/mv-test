require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe MigrationValidators::Spec::Macros::DBMacros, "supports", :type => :mv_test do
  before :all do
    use_memory_db
  end

  describe :for_column, "creates column for each internal test" do
    for_table :test_table do
      for_column :column, :integer do
        it { db.column_exists?(:test_table, :column).should be_true }
        it { db.columns(:test_table).find{|col| col.name.to_s == "column"}.type.to_s.should ==  "integer" }
      end
    end
  end

  describe :with_validator do
  end

  describe :with_option do
  end

  describe :with_change do
  end
end
