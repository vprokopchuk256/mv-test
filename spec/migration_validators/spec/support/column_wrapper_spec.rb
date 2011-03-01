require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe MigrationValidators::Spec::Support::ColumnWrapper, "supports", :type => :mv_test do
  before :each do
    use_memory_db

    db.drop_table(:test_table) if db.table_exists?(:test_table)
    @wrapper = new_table {|t| t.string :str_column }.str_column
  end

  it "drop" do
    chg_table(:test_table) {|t| t.string :str_column_1}.str_column_1.drop

    db.column_exists?(:test_table, :str_column_1).should be_false
  end

  describe "sql wrapping for" do
    before :each do
      db.drop_table(:items) if db.table_exists?(:items)

      Item = Class.new(ActiveRecord::Base) do
        def self.all
          Item.find(:all, :order => "column ASC").collect{|item| item.column}
        end
      end
    end

    describe :insert do
      describe "range" do
        it "open" do
          new_table(:items){|t| t.integer :column}.column.insert(1..3)
          Item.all.should == [1, 2, 3]
        end

        it "closed" do
          new_table(:items){|t| t.integer :column}.column.insert(1...3)
          Item.all.should == [1, 2]
        end
      end

      describe "array" do
        before :each do
          @column = new_table(:items){|t| t.integer :column}.column
        end

        it "of simple elements" do
          @column.insert([1, 2, 3])
          Item.all.should == [1, 2, 3]
        end

        it "as params list" do
          @column.insert(1, 2, 3)
          Item.all.should == [1, 2, 3]
        end

        it "as composite elements" do
          @column.insert(1, 2, 3, [4, 5], 6..8)
          Item.all.should == [1, 2, 3, 4, 5, 6, 7, 8]
        end
      end

      describe "string" do
        before :each do
          @column = new_table(:items){|t| t.string :column}.column
        end

        it "parameters"  do
          @column.insert("str1", "str2")
          Item.all.should == ["str1", "str2"]
        end

        it "interprets NULL correctly" do
          @column.insert("NULL")

          Item.all.should == [nil]
        end

        it "supports internal arrays" do
          @column.insert(["str1", ["str2"]])
          Item.all.should == ["str1", "str2"]
        end
      end

      it "date" do
        column = new_table(:items){|t| t.date :column}.column
        date = Date.today

        column.insert(date)
        Item.all.should == [date]
      end

      it "time" do
        column = new_table(:items){|t| t.time :column}.column
        time = Time.now

        column.insert(time)
        Item.all.first.strftime("%H:%M:%S").should == time.strftime("%H:%M:%S")
      end
      it "datetime" do
        column = new_table(:items){|t| t.datetime :column}.column
        datetime = DateTime.now

        column.insert(datetime)
        Item.all.first.strftime("%y-%m-%d %H:%M:%S").should == datetime.strftime("%y-%m-%d %H:%M:%S")
      end

      it "nil" do
        column = new_table(:items){|t| t.string :column}.column
        column.insert(nil)

        Item.all.should == [nil]
      end
    end

    it :update do
      new_table(:items){|t| t.integer :column}.column.insert(1..3).update(3)
      Item.all.should == [3, 3, 3]
    end
  end

  describe "last exception" do
    it "equals nil if operation successed" do
      column = new_table(:items){|t| t.string :column}.column
      column.insert("value")

      column.last_exception.should be_blank
    end

    it "equals last exception if something wrong" do
      column = new_table(:items){|t| t.string :column}.column
      db.drop_table(:items)
      column.insert("value")

      column.last_exception.should_not be_blank
    end

    it "clears before each new request" do
      column = new_table(:items){|t| t.string :column}.column
      db.drop_table(:items)
      column.insert("value")

      new_table(:items){|t| t.string :column}
      column.insert("value")

      column.last_exception.should be_blank
    end
  end
end
