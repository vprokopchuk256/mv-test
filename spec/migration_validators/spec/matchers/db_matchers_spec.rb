require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe MigrationValidators::Spec::Matchers::DBMatchers, "supports", :type => :mv_test do
  before :all do
    use_memory_db
  end

  before :each do
    db.drop_table(:test_table) if db.table_exists?(:test_table)

    migrate do
      create_table :test_table do |t| 
        t.string :column
      end

      add_index :test_table, :column, :unique => true
    end

    @column = table(:test_table).column
  end

  describe :allow do
    it { @column.should allow.insert(1, 2) }
    it { @column.should allow.update(2).with_initial(1) }
    it { @column.should allow(1) }
    it { @column.should allow.at_least_one(1, 1) }
    it { @column.should allow.insert.at_least_one(1, 1) }
    it { @column.should allow.update.at_least_one(1, 1) }
  end

  describe :deny do
    it { @column.should deny.at_least_one(1, 1).with_initial(1, 2) }
    it { @column.should deny.at_least_one.insert(1, 1) }
    it { @column.should deny.at_least_one.insert(1, 1).with_message(/not unique/) }
    it { @column.should deny.insert(1, 1).with_initial(1).with_message(/not unique/) }
  end
end
