require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe MigrationValidators::Spec::Support::TableWrapper, "supports", :type => :mv_test do
  before :each do
    use_memory_db

    db.drop_table(:test_table) if db.table_exists?(:test_table)
    @wrapper = new_table {|t| t.string :str_column }
  end

  it "column information requests" do
    @wrapper.str_column.column_name.should == :str_column
  end

  it "supports dropping" do
    @wrapper.drop

    db.table_exists?(:test_table).should be_false
  end
end
