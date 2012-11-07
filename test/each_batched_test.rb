require 'test_helper'

# None of these tests test that the algorithm internals work properly/efficiently,
# just that the results give the correct rows in the correct order
# You'd have to examine log files and stuff to make sure the algorithm isn't doing anything extra that it shouldn't
class EachBatchedTest < ActiveSupport::TestCase
  
  context 'with a simple table,' do
    setup do
      @c  = Company
      @c1 = @c.create!(:sort => 4)
      @c2 = @c.create!(:sort => 3)
      @c3 = @c.create!(:sort => 2)
      @c4 = @c.create!(:sort => 1)
    end
    context "with id order," do
      setup { @ord = @c.order(:id) }
      context "and batch size divisible by total" do
        should("br") { assert_equal [[@c1, @c2], [@c3, @c4]], [].tap { |a| @ord.batches_by_range(2) { |r| a << r } } }
        should("bi") { assert_equal [[@c1, @c2], [@c3, @c4]], [].tap { |a| @ord.batches_by_ids(2)   { |r| a << r } } }
        should("er") { assert_equal [@c1, @c2, @c3, @c4],     [].tap { |a| @ord.each_by_range(2)    { |r| a << r } } }
        should("ei") { assert_equal [@c1, @c2, @c3, @c4],     [].tap { |a| @ord.each_by_ids(2)      { |r| a << r } } }
      end
      context "and batch size not evenly divisible by total" do
        should("br") { assert_equal [[@c1, @c2, @c3], [@c4]], [].tap { |a| @ord.batches_by_range(3) { |r| a << r } } }
        should("bi") { assert_equal [[@c1, @c2, @c3], [@c4]], [].tap { |a| @ord.batches_by_ids(3)   { |r| a << r } } }
        should("er") { assert_equal [@c1, @c2, @c3, @c4],     [].tap { |a| @ord.each_by_range(3)    { |r| a << r } } }
        should("ei") { assert_equal [@c1, @c2, @c3, @c4],     [].tap { |a| @ord.each_by_ids(3)      { |r| a << r } } }
      end
      context "and an offset" do
        setup { @off = @ord.offset(1) }
        should("br") { assert_equal [[@c2, @c3], [@c4]], [].tap { |a| @off.batches_by_range(2) { |r| a << r } } }
        should("bi") { assert_equal [[@c2, @c3], [@c4]], [].tap { |a| @off.batches_by_ids(2)   { |r| a << r } } }
        should("er") { assert_equal [@c2, @c3, @c4],     [].tap { |a| @off.each_by_range(2)    { |r| a << r } } }
        should("ei") { assert_equal [@c2, @c3, @c4],     [].tap { |a| @off.each_by_ids(2)      { |r| a << r } } }
      end
      context "and a limit" do
        setup { @lim = @ord.limit(3) }
        should("br") { assert_equal [[@c1, @c2], [@c3]], [].tap { |a| @lim.batches_by_range(2) { |r| a << r } } }
        should("bi") { assert_equal [[@c1, @c2], [@c3]], [].tap { |a| @lim.batches_by_ids(2)   { |r| a << r } } }
        should("er") { assert_equal [@c1, @c2, @c3],     [].tap { |a| @lim.each_by_range(2)    { |r| a << r } } }
        should("ei") { assert_equal [@c1, @c2, @c3],     [].tap { |a| @lim.each_by_ids(2)      { |r| a << r } } }
      end
    end
    context "with sort order" do
      setup { @ord = @c.order(:sort) }
      should("br") { assert_equal [[@c4, @c3], [@c2, @c1]], [].tap { |a| @ord.batches_by_range(2) { |r| a << r } } }
      should("bi") { assert_equal [[@c4, @c3], [@c2, @c1]], [].tap { |a| @ord.batches_by_ids(2)   { |r| a << r } } }
      should("er") { assert_equal [@c4, @c3, @c2, @c1],     [].tap { |a| @ord.each_by_range(2)    { |r| a << r } } }
      should("ei") { assert_equal [@c4, @c3, @c2, @c1],     [].tap { |a| @ord.each_by_ids(2)      { |r| a << r } } }
    end
    context "with order set in the select" do
      setup { @ord = @c.select('companies.*, companies.sort + 1 AS foo').order('foo') }
      should("br") { assert_equal [[@c4, @c3], [@c2, @c1]], [].tap { |a| @ord.batches_by_range(2) { |r| a << r } } }
      #should("bi") { assert_equal [[@c4, @c3], [@c2, @c1]], [].tap { |a| @ord.batches_by_ids(2)   { |r| a << r } } }
      should("er") { assert_equal [@c4, @c3, @c2, @c1],     [].tap { |a| @ord.each_by_range(2)    { |r| a << r } } }
      #should("ei") { assert_equal [@c4, @c3, @c2, @c1],     [].tap { |a| @ord.each_by_ids(2)      { |r| a << r } } }
    end
  end
  
  context "with a has_many association," do
    setup do
      com = Company.create!
      @c  = com.customers
      @c1 = @c.create!(:sort => 4)
      @c2 = @c.create!(:sort => 3)
      @c3 = @c.create!(:sort => 2)
      @c4 = @c.create!(:sort => 1)
    end
    context "with id order," do
      setup { @ord = @c.order('customers.id') }
      context "and batch size divisible by total" do
        should("br") { assert_equal [[@c1, @c2], [@c3, @c4]], [].tap { |a| @ord.batches_by_range(2) { |r| a << r } } }
        should("bi") { assert_equal [[@c1, @c2], [@c3, @c4]], [].tap { |a| @ord.batches_by_ids(2)   { |r| a << r } } }
        should("er") { assert_equal [@c1, @c2, @c3, @c4],     [].tap { |a| @ord.each_by_range(2)    { |r| a << r } } }
        should("ei") { assert_equal [@c1, @c2, @c3, @c4],     [].tap { |a| @ord.each_by_ids(2)      { |r| a << r } } }
      end
      context "and batch size not evenly divisible by total" do
        should("br") { assert_equal [[@c1, @c2, @c3], [@c4]], [].tap { |a| @ord.batches_by_range(3) { |r| a << r } } }
        should("bi") { assert_equal [[@c1, @c2, @c3], [@c4]], [].tap { |a| @ord.batches_by_ids(3)   { |r| a << r } } }
        should("er") { assert_equal [@c1, @c2, @c3, @c4],     [].tap { |a| @ord.each_by_range(3)    { |r| a << r } } }
        should("ei") { assert_equal [@c1, @c2, @c3, @c4],     [].tap { |a| @ord.each_by_ids(3)      { |r| a << r } } }
      end
      context "and an offset" do
        setup { @off = @ord.offset(1) }
        should("br") { assert_equal [[@c2, @c3], [@c4]], [].tap { |a| @off.batches_by_range(2) { |r| a << r } } }
        should("bi") { assert_equal [[@c2, @c3], [@c4]], [].tap { |a| @off.batches_by_ids(2)   { |r| a << r } } }
        should("er") { assert_equal [@c2, @c3, @c4],     [].tap { |a| @off.each_by_range(2)    { |r| a << r } } }
        should("ei") { assert_equal [@c2, @c3, @c4],     [].tap { |a| @off.each_by_ids(2)      { |r| a << r } } }
      end
      context "and a limit" do
        setup { @lim = @ord.limit(3) }
        should("br") { assert_equal [[@c1, @c2], [@c3]], [].tap { |a| @lim.batches_by_range(2) { |r| a << r } } }
        should("bi") { assert_equal [[@c1, @c2], [@c3]], [].tap { |a| @lim.batches_by_ids(2)   { |r| a << r } } }
        should("er") { assert_equal [@c1, @c2, @c3],     [].tap { |a| @lim.each_by_range(2)    { |r| a << r } } }
        should("ei") { assert_equal [@c1, @c2, @c3],     [].tap { |a| @lim.each_by_ids(2)      { |r| a << r } } }
      end
    end
    context "with sort order" do
      setup { @ord = @c.order('customers.sort') }
      should("br") { assert_equal [[@c4, @c3], [@c2, @c1]], [].tap { |a| @ord.batches_by_range(2) { |r| a << r } } }
      should("bi") { assert_equal [[@c4, @c3], [@c2, @c1]], [].tap { |a| @ord.batches_by_ids(2)   { |r| a << r } } }
      should("er") { assert_equal [@c4, @c3, @c2, @c1],     [].tap { |a| @ord.each_by_range(2)    { |r| a << r } } }
      should("ei") { assert_equal [@c4, @c3, @c2, @c1],     [].tap { |a| @ord.each_by_ids(2)      { |r| a << r } } }
    end
    context "with order set in the select" do
      setup { @ord = @c.select('customers.*, customers.sort + 1 AS foo').order('foo') }
      should("br") { assert_equal [[@c4, @c3], [@c2, @c1]], [].tap { |a| @ord.batches_by_range(2) { |r| a << r } } }
      #should("bi") { assert_equal [[@c4, @c3], [@c2, @c1]], [].tap { |a| @ord.batches_by_ids(2)   { |r| a << r } } }
      should("er") { assert_equal [@c4, @c3, @c2, @c1],     [].tap { |a| @ord.each_by_range(2)    { |r| a << r } } }
      #should("ei") { assert_equal [@c4, @c3, @c2, @c1],     [].tap { |a| @ord.each_by_ids(2)      { |r| a << r } } }
    end
  end
  
  context "with a has_many through has_many association," do
    setup do
      com = Company.create!
      com.customers.create!
      pro = com.products.create!
      pur = com.customers[0].purchases
      @c1 = pur.create!(:product => pro, :ordered_on => Date.parse('Jan 4 2011'))
      @c2 = pur.create!(:product => pro, :ordered_on => Date.parse('Jan 3 2011'))
      @c3 = pur.create!(:product => pro, :ordered_on => Date.parse('Jan 2 2011'))
      @c4 = pur.create!(:product => pro, :ordered_on => Date.parse('Jan 1 2011'))
      @c  = com.customer_purchases
    end
    context "with id order," do
      setup { @ord = @c.order('purchases.id') }
      context "and batch size divisible by total" do
        should("br") { assert_equal [[@c1, @c2], [@c3, @c4]], [].tap { |a| @ord.batches_by_range(2) { |r| a << r } } }
        should("bi") { assert_equal [[@c1, @c2], [@c3, @c4]], [].tap { |a| @ord.batches_by_ids(2)   { |r| a << r } } }
        should("er") { assert_equal [@c1, @c2, @c3, @c4],     [].tap { |a| @ord.each_by_range(2)    { |r| a << r } } }
        should("ei") { assert_equal [@c1, @c2, @c3, @c4],     [].tap { |a| @ord.each_by_ids(2)      { |r| a << r } } }
      end
      context "and batch size not evenly divisible by total" do
        should("br") { assert_equal [[@c1, @c2, @c3], [@c4]], [].tap { |a| @ord.batches_by_range(3) { |r| a << r } } }
        should("bi") { assert_equal [[@c1, @c2, @c3], [@c4]], [].tap { |a| @ord.batches_by_ids(3)   { |r| a << r } } }
        should("er") { assert_equal [@c1, @c2, @c3, @c4],     [].tap { |a| @ord.each_by_range(3)    { |r| a << r } } }
        should("ei") { assert_equal [@c1, @c2, @c3, @c4],     [].tap { |a| @ord.each_by_ids(3)      { |r| a << r } } }
      end
      context "and an offset" do
        setup { @off = @ord.offset(1) }
        should("br") { assert_equal [[@c2, @c3], [@c4]], [].tap { |a| @off.batches_by_range(2) { |r| a << r } } }
        should("bi") { assert_equal [[@c2, @c3], [@c4]], [].tap { |a| @off.batches_by_ids(2)   { |r| a << r } } }
        should("er") { assert_equal [@c2, @c3, @c4],     [].tap { |a| @off.each_by_range(2)    { |r| a << r } } }
        should("ei") { assert_equal [@c2, @c3, @c4],     [].tap { |a| @off.each_by_ids(2)      { |r| a << r } } }
      end
      context "and a limit" do
        setup { @lim = @ord.limit(3) }
        should("br") { assert_equal [[@c1, @c2], [@c3]], [].tap { |a| @lim.batches_by_range(2) { |r| a << r } } }
        should("bi") { assert_equal [[@c1, @c2], [@c3]], [].tap { |a| @lim.batches_by_ids(2)   { |r| a << r } } }
        should("er") { assert_equal [@c1, @c2, @c3],     [].tap { |a| @lim.each_by_range(2)    { |r| a << r } } }
        should("ei") { assert_equal [@c1, @c2, @c3],     [].tap { |a| @lim.each_by_ids(2)      { |r| a << r } } }
      end
    end
    context "with sort order" do
      setup { @ord = @c.order('purchases.ordered_on') }
      should("br") { assert_equal [[@c4, @c3], [@c2, @c1]], [].tap { |a| @ord.batches_by_range(2) { |r| a << r } } }
      should("bi") { assert_equal [[@c4, @c3], [@c2, @c1]], [].tap { |a| @ord.batches_by_ids(2)   { |r| a << r } } }
      should("er") { assert_equal [@c4, @c3, @c2, @c1],     [].tap { |a| @ord.each_by_range(2)    { |r| a << r } } }
      should("ei") { assert_equal [@c4, @c3, @c2, @c1],     [].tap { |a| @ord.each_by_ids(2)      { |r| a << r } } }
    end
    context "with order set in the select" do
      setup { @ord = @c.select("purchases.*, DATE(purchases.ordered_on, '+1 DAY') AS foo").order('foo') }
      should("br") { assert_equal [[@c4, @c3], [@c2, @c1]], [].tap { |a| @ord.batches_by_range(2) { |r| a << r } } }
      #should("bi") { assert_equal [[@c4, @c3], [@c2, @c1]], [].tap { |a| @ord.batches_by_ids(2)   { |r| a << r } } }
      should("er") { assert_equal [@c4, @c3, @c2, @c1],     [].tap { |a| @ord.each_by_range(2)    { |r| a << r } } }
      #should("ei") { assert_equal [@c4, @c3, @c2, @c1],     [].tap { |a| @ord.each_by_ids(2)      { |r| a << r } } }
    end
  end
  
  context "with a has_many through has_many through belongs_to unique association," do
    setup do
      com = Company.create!
      com.customers.create!
      @c1 = com.products.create!(:sort => 4)
      @c2 = com.products.create!(:sort => 3)
      @c3 = com.products.create!(:sort => 2)
      @c4 = com.products.create!(:sort => 1)
            com.products.create!(:sort => 0)
      pur = com.customers[0].purchases
      pur.create!(:product => @c1)
      pur.create!(:product => @c2)
      pur.create!(:product => @c3)
      pur.create!(:product => @c4)
      pur.create!(:product => @c2)
      @c  = com.purchased_products
    end
    context "with id order," do
      setup { @ord = @c.order('products.id') }
      context "and batch size divisible by total" do
        should("br") { assert_equal [[@c1, @c2], [@c3, @c4]], [].tap { |a| @ord.batches_by_range(2) { |r| a << r } } }
        should("bi") { assert_equal [[@c1, @c2], [@c3, @c4]], [].tap { |a| @ord.batches_by_ids(2)   { |r| a << r } } }
        should("er") { assert_equal [@c1, @c2, @c3, @c4],     [].tap { |a| @ord.each_by_range(2)    { |r| a << r } } }
        should("ei") { assert_equal [@c1, @c2, @c3, @c4],     [].tap { |a| @ord.each_by_ids(2)      { |r| a << r } } }
      end
      context "and batch size not evenly divisible by total" do
        should("br") { assert_equal [[@c1, @c2, @c3], [@c4]], [].tap { |a| @ord.batches_by_range(3) { |r| a << r } } }
        should("bi") { assert_equal [[@c1, @c2, @c3], [@c4]], [].tap { |a| @ord.batches_by_ids(3)   { |r| a << r } } }
        should("er") { assert_equal [@c1, @c2, @c3, @c4],     [].tap { |a| @ord.each_by_range(3)    { |r| a << r } } }
        should("ei") { assert_equal [@c1, @c2, @c3, @c4],     [].tap { |a| @ord.each_by_ids(3)      { |r| a << r } } }
      end
      context "and an offset" do
        setup { @off = @ord.offset(1) }
        should("br") { assert_equal [[@c2, @c3], [@c4]], [].tap { |a| @off.batches_by_range(2) { |r| a << r } } }
        should("bi") { assert_equal [[@c2, @c3], [@c4]], [].tap { |a| @off.batches_by_ids(2)   { |r| a << r } } }
        should("er") { assert_equal [@c2, @c3, @c4],     [].tap { |a| @off.each_by_range(2)    { |r| a << r } } }
        should("ei") { assert_equal [@c2, @c3, @c4],     [].tap { |a| @off.each_by_ids(2)      { |r| a << r } } }
      end
      context "and a limit" do
        setup { @lim = @ord.limit(3) }
        should("br") { assert_equal [[@c1, @c2], [@c3]], [].tap { |a| @lim.batches_by_range(2) { |r| a << r } } }
        should("bi") { assert_equal [[@c1, @c2], [@c3]], [].tap { |a| @lim.batches_by_ids(2)   { |r| a << r } } }
        should("er") { assert_equal [@c1, @c2, @c3],     [].tap { |a| @lim.each_by_range(2)    { |r| a << r } } }
        should("ei") { assert_equal [@c1, @c2, @c3],     [].tap { |a| @lim.each_by_ids(2)      { |r| a << r } } }
      end
    end
    context "with sort order" do
      setup { @ord = @c.order('products.sort') }
      should("br") { assert_equal [[@c4, @c3], [@c2, @c1]], [].tap { |a| @ord.batches_by_range(2) { |r| a << r } } }
      should("bi") { assert_equal [[@c4, @c3], [@c2, @c1]], [].tap { |a| @ord.batches_by_ids(2)   { |r| a << r } } }
      should("er") { assert_equal [@c4, @c3, @c2, @c1],     [].tap { |a| @ord.each_by_range(2)    { |r| a << r } } }
      should("ei") { assert_equal [@c4, @c3, @c2, @c1],     [].tap { |a| @ord.each_by_ids(2)      { |r| a << r } } }
    end
    context "with order set in the select" do
      setup { @ord = @c.select('products.*, products.sort + 1 AS foo').order('foo') }
      should("br") { assert_equal [[@c4, @c3], [@c2, @c1]], [].tap { |a| @ord.batches_by_range(2) { |r| a << r } } }
      #should("bi") { assert_equal [[@c4, @c3], [@c2, @c1]], [].tap { |a| @ord.batches_by_ids(2)   { |r| a << r } } }
      should("er") { assert_equal [@c4, @c3, @c2, @c1],     [].tap { |a| @ord.each_by_range(2)    { |r| a << r } } }
      #should("ei") { assert_equal [@c4, @c3, @c2, @c1],     [].tap { |a| @ord.each_by_ids(2)      { |r| a << r } } }
    end
  end
  
  # TODO: any more complicated queries?
end
