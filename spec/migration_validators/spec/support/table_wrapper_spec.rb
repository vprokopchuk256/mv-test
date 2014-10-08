require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe MigrationValidators::Spec::Support::TableWrapper, "supports", :type => :mv_test do
  before :example do
    use_memory_db
  end

  before { db.create_table(:table_name) {|tbl| tbl.string :column} }
  after { db.drop_table(:table_name) if db.table_exists?(:table_name) }

  subject(:tbl){ described_class.new(:table_name, db) }

  describe '#initialize' do
    its(:table_name) { is_expected.to eq(:table_name) }
  end

  describe '#drop' do
    before{ tbl.drop }

    subject{ db.table_exists?(:table_name) }

    it { is_expected.to eq(false) }
  end

  describe 'access column by name' do
    subject{ tbl.column }

    it { is_expected.to be_present }
    its(:column_name) { is_expected.to eq(:column) }
  end
end
