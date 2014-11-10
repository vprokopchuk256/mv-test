require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe MigrationValidators::Spec::Matchers::DBMatchers, "supports", :type => :mv_test do
  before :example do
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
  end

  subject{ table(:test_table).column }

  describe :allow do
    it { is_expected.to allow.insert(1, 2) }
    it { is_expected.to allow.update(2).with_initial(1) }
    it { is_expected.to allow(1) }
    it { is_expected.to allow.at_least_one(1, 1) }
    it { is_expected.to allow.insert.at_least_one(1, 1) }
    it { is_expected.to allow.update.at_least_one(1, 1) }
  end

  describe :deny do
    it { is_expected.to deny.at_least_one(1, 1).with_initial(1, 2) }
    it { is_expected.to deny.at_least_one.insert(1, 1) }
    it { is_expected.to deny.at_least_one.insert(1, 1).with_message(/is not unique/) }
    it { is_expected.to deny.insert(1, 1).with_initial(1).with_message(/is not unique/) }
  end
end
