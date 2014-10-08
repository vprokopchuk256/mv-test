require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe MigrationValidators::Spec::Support::ColumnWrapper, "supports", :type => :mv_test do
  Item = Class.new(ActiveRecord::Base)

  before :example do 
    use_memory_db 
    new_table(:items) do |t| 
      t.column :string_column, :string 
      t.column :integer_column, :integer 
      t.column :date_column, :date 
      t.column :time_column, :time 
      t.column :datetime_column, :datetime
    end
  end

  after :example do 
    db.drop_table(:items)
  end

  after do
    db.execute('DELETE FROM items')
  end

  let(:items_table) { table(:items) }

  describe '#initialize' do
    subject{ described_class.new(:string_column, items_table, db) }

    its(:column_name) { is_expected.to eq(:string_column) }
    its(:last_exception) { is_expected.to be_nil }
  end

  describe '#drop' do
    before { items_table.string_column.drop }

    subject{ db.column_exists?(:items, :string_column) }

    it { should eq(false) }

    after { chg_table(:items){|tbl| tbl.string :string_column} }
  end

  describe '#insert' do
    before do
      column.insert(params)
    end

    context 'collection passed as' do
      let(:column) { items_table.integer_column }
      subject{ Item.all.collect(&:integer_column) }

      context 'open range' do
        let(:params) { 1..3 }
        
        it { is_expected.to match_array([1, 2, 3]) }
      end

      context 'closed range' do
        let(:params) { 1...3 }
        
        it { is_expected.to match_array([1, 2]) }
      end

      context 'flat array' do
        let(:params) { [1, 2, 3] }
        
        it { is_expected.to match_array([1, 2, 3]) }
      end

      context 'array with inner collections' do
        let(:params) { [1, 2, 3, [4, 5], 6..8] }
        
        it { is_expected.to match_array([1, 2, 3, 4, 5, 6, 7, 8]) }
      end
    end

    context 'inserted single value' do
      let(:column) { |example| items_table.send(:"#{example.metadata[:described_class]}_column") }
      let(:params) { |example| example.metadata[:value_to_insert] }
      let(:value_to_insert) { params }
      subject{ |example| Item.first.send(:"#{example.metadata[:described_class]}_column") }

      context :string, value_to_insert: 'str' do
        it { is_expected.to eq("str") } 
      end

      context :string, value_to_insert: 'NULL' do
        it { is_expected.to be_nil } 
      end

      context :date, value_to_insert: Date.today do
        it { is_expected.to eq(Date.today) } 
      end

      context :time, value_to_insert: Time.now do
        its(:hour) { is_expected.to eq(value_to_insert.hour) } 
        its(:min) { is_expected.to eq(value_to_insert.min) } 
        its(:sec) { is_expected.to eq(value_to_insert.sec) } 
      end

      context :datetime, value_to_insert: DateTime.now do
        its(:year) { is_expected.to eq(value_to_insert.year) } 
        its(:mon) { is_expected.to eq(value_to_insert.mon) } 
        its(:day) { is_expected.to eq(value_to_insert.day) } 
        its(:hour) { is_expected.to eq(value_to_insert.hour) } 
        its(:min) { is_expected.to eq(value_to_insert.min) } 
        its(:sec) { is_expected.to eq(value_to_insert.sec) } 
      end
    end
  end

  describe '#update' do
    let(:column_name) { |example| :"#{example.metadata[:described_class]}_column" }
    let(:column) { |example| items_table.send(column_name) }
    let(:new_value) { |example| example.metadata[:new_value] }

    before do |example| 
      column.insert(example.metadata[:old_value]) 
      column.update(example.metadata[:new_value])
    end

    subject{ |example| Item.first.send(column_name) }
    
    context :string, old_value: 'old_str', new_value: 'new_str' do
      it { is_expected.to eq(new_value) } 
    end

    context :string, old_value: 'old_str', new_value: 'NULL' do
      it { is_expected.to be_nil } 
    end

    context :date, old_value: Date.yesterday, new_value: Date.today do
      it { is_expected.to eq(new_value) } 
    end

    context :time, old_value: Time.now - 1, new_value: Time.now do
      its(:hour) { is_expected.to eq(new_value.hour) } 
      its(:min) { is_expected.to eq(new_value.min) } 
      its(:sec) { is_expected.to eq(new_value.sec) } 
    end

    context :datetime, old_value: Time.now - 1000, new_value: DateTime.now do
      its(:year) { is_expected.to eq(new_value.year) } 
      its(:mon) { is_expected.to eq(new_value.mon) } 
      its(:day) { is_expected.to eq(new_value.day) } 
      its(:hour) { is_expected.to eq(new_value.hour) } 
      its(:min) { is_expected.to eq(new_value.min) } 
      its(:sec) { is_expected.to eq(new_value.sec) } 
    end
  end

  describe '#to_array for array that contains' do
    let(:value) { |example| example.metadata[:value] }
    subject{ MigrationValidators::Spec::Support::ColumnWrapper.to_array([value]) }

    context Array, value: [1, 2, 3] do
      it { is_expected.to match_array([1, 2, 3]) }
    end

    context Range, value: 1..3 do
      it { is_expected.to match_array([1, 2, 3]) }
    end

    context Integer, value: 1 do
      it { is_expected.to eq([1]) }
    end

    context String, value: 'str' do
      it { is_expected.to eq(["'str'"]) }
    end

    context Date, value: Date.today do
      it { is_expected.to eq(["'#{value.strftime('%Y-%m-%d')}'"]) }
    end

    context Time, value: Time.now do
      it { is_expected.to eq(["'#{value.strftime('%Y-%m-%d %H:%M:%S')}'"]) }
    end

    context DateTime, value: DateTime.now do
      it { is_expected.to eq(["'#{value.strftime('%Y-%m-%d %H:%M:%S')}'"]) }
    end

    context NilClass, value: nil do
      it { is_expected.to eq(["NULL"]) }
    end
  end
end
