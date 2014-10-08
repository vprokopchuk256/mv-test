require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe MigrationValidators::Spec::Macros::DBMacros, "supports", :type => :mv_test do
  before :all do
    use_memory_db
  end

  describe :for_column, "creates column for each internal test" do
    for_table :test_table do
      for_column :column, :integer do
        context 'existence' do
          subject{ db.column_exists?(:test_table, :column) }

          it { should eq(true)}
        end

        context 'column type' do
          subject{ db.columns(:test_table).find{|col| col.name.to_s == "column"}.type.to_s }

          it { should eq('integer')}
        end
      end
    end
  end
end
