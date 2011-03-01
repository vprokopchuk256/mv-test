require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe MigrationValidators::Spec::Support::DB, "supports", :type => :mv_test do
  it "connect to the memory db (sqlite in memory)" do
    use_memory_db

    ActiveRecord::Base.connection.should_not be_blank
  end

  it "shortcut to active record connection" do
    use_memory_db

    db.should == ActiveRecord::Base.connection
  end

  it "migration shortcut" do
    db.drop_table(:test_table) if db.table_exists?(:test_table)

    migrate do
      create_table :test_table do |t|
        t.string :str_column
      end
    end

    db.table_exists?(:test_table).should be_true
  end

  it "create table shortcut" do
    db.drop_table(:test_table) if db.table_exists?(:test_table)

    new_table :test_table do |t|
      t.string :str_column
    end
    
    db.table_exists?(:test_table).should be_true
  end

  it "change table shortcut" do
    db.drop_table(:test_table) if db.table_exists?(:test_table)
    new_table {|t| t.string :str_column }

    chg_table :test_table do |t|
      t.string :str_column_1
    end

    db.column_exists?(:test_table, :str_column_1).should be_true
  end

  it "shortcut for table info" do
    db.drop_table(:test_table) if db.table_exists?(:test_table)
    new_table {|t| t.string :str_column }

    table(:test_table).should be_kind_of(MigrationValidators::Spec::Support::TableWrapper)
    table(:test_table).table_name.should == :test_table
  end
end
