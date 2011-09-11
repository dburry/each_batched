require 'test_helper'

# None of these tests test that the algorithm internals work properly/efficiently,
# just that the results give the correct rows in the correct order
# You'd have to examine log files and stuff to make sure the algorithm isn't doing anything extra that it shouldn't
class EachBatchedTest < ActiveSupport::TestCase
  
  context 'with a simple table' do
    setup do
      @c  = Company
      @c1 = @c.create!(:sort => 4)
      @c2 = @c.create!(:sort => 3)
      @c3 = @c.create!(:sort => 2)
      @c4 = @c.create!(:sort => 1)
      @co = @c.order(:id) # default order to use
    end
    
    context "batches_by_range" do
      should("divisible") { assert_equal [[@c1, @c2], [@c3, @c4]], [].tap { |a| @co.batches_by_range(2) { |r| a << r } } }
      should("noneven")   { assert_equal [[@c1, @c2, @c3], [@c4]], [].tap { |a| @co.batches_by_range(3) { |r| a << r } } }
      should("offset")    { assert_equal [[@c2, @c3], [@c4]], [].tap { |a| @co.offset(1).batches_by_range(2) { |r| a << r } } }
      should("limit")     { assert_equal [[@c1, @c2], [@c3]], [].tap { |a| @co.limit(3).batches_by_range(2) { |r| a << r } } }
      should("ordered")   { assert_equal [[@c4, @c3], [@c2, @c1]], [].tap { |a| @c.order(:sort).batches_by_range(2) { |r| a << r } } }
    end
    context "batches_by_ids" do
      should("divisible") { assert_equal [[@c1, @c2], [@c3, @c4]], [].tap { |a| @co.batches_by_ids(2) { |r| a << r } } }
      should("noneven")   { assert_equal [[@c1, @c2, @c3], [@c4]], [].tap { |a| @co.batches_by_ids(3) { |r| a << r } } }
      should("offset")    { assert_equal [[@c2, @c3], [@c4]], [].tap { |a| @co.offset(1).batches_by_ids(2) { |r| a << r } } }
      should("limit")     { assert_equal [[@c1, @c2], [@c3]], [].tap { |a| @co.limit(3).batches_by_ids(2) { |r| a << r } } }
      should("ordered")   { assert_equal [[@c4, @c3], [@c2, @c1]], [].tap { |a| @c.order(:sort).batches_by_ids(2) { |r| a << r } } }
    end
    context "each_by_range" do
      should("divisible") { assert_equal [@c1, @c2, @c3, @c4], [].tap { |a| @co.each_by_range(2) { |r| a << r } } }
      should("noneven")   { assert_equal [@c1, @c2, @c3, @c4], [].tap { |a| @co.each_by_range(3) { |r| a << r } } }
      should("offset")    { assert_equal [@c2, @c3, @c4], [].tap { |a| @co.offset(1).each_by_range(2) { |r| a << r } } }
      should("limit")     { assert_equal [@c1, @c2, @c3], [].tap { |a| @co.limit(3).each_by_range(2) { |r| a << r } } }
      should("ordered")   { assert_equal [@c4, @c3, @c2, @c1], [].tap { |a| @c.order(:sort).each_by_range(2) { |r| a << r } } }
    end
    context "each_by_ids" do
      should("divisible") { assert_equal [@c1, @c2, @c3, @c4], [].tap { |a| @co.each_by_ids(2) { |r| a << r } } }
      should("noneven")   { assert_equal [@c1, @c2, @c3, @c4], [].tap { |a| @co.each_by_ids(3) { |r| a << r } } }
      should("offset")    { assert_equal [@c2, @c3, @c4], [].tap { |a| @co.offset(1).each_by_ids(2) { |r| a << r } } }
      should("limit")     { assert_equal [@c1, @c2, @c3], [].tap { |a| @co.limit(3).each_by_ids(2) { |r| a << r } } }
      should("ordered")   { assert_equal [@c4, @c3, @c2, @c1], [].tap { |a| @c.order(:sort).each_by_ids(2) { |r| a << r } } }
    end
    
  end
  
  context "with a has_many association" do
    setup do
      com = Company.create!
      @c  = com.customers
      @c1 = @c.create!(:sort => 4)
      @c2 = @c.create!(:sort => 3)
      @c3 = @c.create!(:sort => 2)
      @c4 = @c.create!(:sort => 1)
      @co = @c.order('customers.id')
    end
    context "batches_by_range" do
      should("divisible") { assert_equal [[@c1, @c2], [@c3, @c4]], [].tap { |a| @co.batches_by_range(2) { |r| a << r } } }
      should("noneven")   { assert_equal [[@c1, @c2, @c3], [@c4]], [].tap { |a| @co.batches_by_range(3) { |r| a << r } } }
      should("offset")    { assert_equal [[@c2, @c3], [@c4]], [].tap { |a| @co.offset(1).batches_by_range(2) { |r| a << r } } }
      should("limit")     { assert_equal [[@c1, @c2], [@c3]], [].tap { |a| @co.limit(3).batches_by_range(2) { |r| a << r } } }
      should("ordered")   { assert_equal [[@c4, @c3], [@c2, @c1]], [].tap { |a| @c.order('customers.sort').batches_by_range(2) { |r| a << r } } }
    end
    context "batches_by_ids" do
      should("divisible") { assert_equal [[@c1, @c2], [@c3, @c4]], [].tap { |a| @co.batches_by_ids(2) { |r| a << r } } }
      should("noneven")   { assert_equal [[@c1, @c2, @c3], [@c4]], [].tap { |a| @co.batches_by_ids(3) { |r| a << r } } }
      should("offset")    { assert_equal [[@c2, @c3], [@c4]], [].tap { |a| @co.offset(1).batches_by_ids(2) { |r| a << r } } }
      should("limit")     { assert_equal [[@c1, @c2], [@c3]], [].tap { |a| @co.limit(3).batches_by_ids(2) { |r| a << r } } }
      should("ordered")   { assert_equal [[@c4, @c3], [@c2, @c1]], [].tap { |a| @c.order('customers.sort').batches_by_ids(2) { |r| a << r } } }
    end
    context "each_by_range" do
      should("divisible") { assert_equal [@c1, @c2, @c3, @c4], [].tap { |a| @co.each_by_range(2) { |r| a << r } } }
      should("noneven")   { assert_equal [@c1, @c2, @c3, @c4], [].tap { |a| @co.each_by_range(3) { |r| a << r } } }
      should("offset")    { assert_equal [@c2, @c3, @c4], [].tap { |a| @co.offset(1).each_by_range(2) { |r| a << r } } }
      should("limit")     { assert_equal [@c1, @c2, @c3], [].tap { |a| @co.limit(3).each_by_range(2) { |r| a << r } } }
      should("ordered")   { assert_equal [@c4, @c3, @c2, @c1], [].tap { |a| @c.order('customers.sort').each_by_range(2) { |r| a << r } } }
    end
    context "each_by_ids" do
      should("divisible") { assert_equal [@c1, @c2, @c3, @c4], [].tap { |a| @co.each_by_ids(2) { |r| a << r } } }
      should("noneven")   { assert_equal [@c1, @c2, @c3, @c4], [].tap { |a| @co.each_by_ids(3) { |r| a << r } } }
      should("offset")    { assert_equal [@c2, @c3, @c4], [].tap { |a| @co.offset(1).each_by_ids(2) { |r| a << r } } }
      should("limit")     { assert_equal [@c1, @c2, @c3], [].tap { |a| @co.limit(3).each_by_ids(2) { |r| a << r } } }
      should("ordered")   { assert_equal [@c4, @c3, @c2, @c1], [].tap { |a| @c.order('customers.sort').each_by_ids(2) { |r| a << r } } }
    end
  end
  
  context "with a has_many through has_many association" do
    setup do
      com = Company.create!
      com.customers.create
      pro = com.products.create
      pur = com.customers[0].purchases
      @p1 = pur.create(:product => pro, :ordered_on => Date.parse('Jan 4 2011'))
      @p2 = pur.create(:product => pro, :ordered_on => Date.parse('Jan 3 2011'))
      @p3 = pur.create(:product => pro, :ordered_on => Date.parse('Jan 2 2011'))
      @p4 = pur.create(:product => pro, :ordered_on => Date.parse('Jan 1 2011'))
      @p  = com.customer_purchases
      @po = @p.order('purchases.id')
    end
    context "batches_by_range" do
      should("divisible") { assert_equal [[@p1, @p2], [@p3, @p4]], [].tap { |a| @po.batches_by_range(2) { |r| a << r } } }
      should("noneven")   { assert_equal [[@p1, @p2, @p3], [@p4]], [].tap { |a| @po.batches_by_range(3) { |r| a << r } } }
      should("offset")    { assert_equal [[@p2, @p3], [@p4]], [].tap { |a| @po.offset(1).batches_by_range(2) { |r| a << r } } }
      should("limit")     { assert_equal [[@p1, @p2], [@p3]], [].tap { |a| @po.limit(3).batches_by_range(2) { |r| a << r } } }
      should("ordered")   { assert_equal [[@p4, @p3], [@p2, @p1]], [].tap { |a| @p.order(:ordered_on).batches_by_range(2) { |r| a << r } } }
    end
    context "batches_by_ids" do
      should("divisible") { assert_equal [[@p1, @p2], [@p3, @p4]], [].tap { |a| @po.batches_by_ids(2) { |r| a << r } } }
      should("noneven")   { assert_equal [[@p1, @p2, @p3], [@p4]], [].tap { |a| @po.batches_by_ids(3) { |r| a << r } } }
      should("offset")    { assert_equal [[@p2, @p3], [@p4]], [].tap { |a| @po.offset(1).batches_by_ids(2) { |r| a << r } } }
      should("limit")     { assert_equal [[@p1, @p2], [@p3]], [].tap { |a| @po.limit(3).batches_by_ids(2) { |r| a << r } } }
      should("ordered")   { assert_equal [[@p4, @p3], [@p2, @p1]], [].tap { |a| @p.order(:ordered_on).batches_by_ids(2) { |r| a << r } } }
    end
    context "each_by_range" do
      should("divisible") { assert_equal [@p1, @p2, @p3, @p4], [].tap { |a| @po.each_by_range(2) { |r| a << r } } }
      should("noneven")   { assert_equal [@p1, @p2, @p3, @p4], [].tap { |a| @po.each_by_range(3) { |r| a << r } } }
      should("offset")    { assert_equal [@p2, @p3, @p4], [].tap { |a| @po.offset(1).each_by_range(2) { |r| a << r } } }
      should("limit")     { assert_equal [@p1, @p2, @p3], [].tap { |a| @po.limit(3).each_by_range(2) { |r| a << r } } }
      should("ordered")   { assert_equal [@p4, @p3, @p2, @p1], [].tap { |a| @p.order(:ordered_on).each_by_range(2) { |r| a << r } } }
    end
    context "each_by_ids" do
      should("divisible") { assert_equal [@p1, @p2, @p3, @p4], [].tap { |a| @po.each_by_ids(2) { |r| a << r } } }
      should("noneven")   { assert_equal [@p1, @p2, @p3, @p4], [].tap { |a| @po.each_by_ids(3) { |r| a << r } } }
      should("offset")    { assert_equal [@p2, @p3, @p4], [].tap { |a| @po.offset(1).each_by_ids(2) { |r| a << r } } }
      should("limit")     { assert_equal [@p1, @p2, @p3], [].tap { |a| @po.limit(3).each_by_ids(2) { |r| a << r } } }
      should("ordered")   { assert_equal [@p4, @p3, @p2, @p1], [].tap { |a| @p.order(:ordered_on).each_by_ids(2) { |r| a << r } } }
    end
  end
  
  context "with a has_many through has_many through belongs_to unique association" do
    setup do
      com = Company.create!
      com.customers.create
      @p1 = com.products.create(:sort => 4)
      @p2 = com.products.create(:sort => 3)
      @p3 = com.products.create(:sort => 2)
      @p4 = com.products.create(:sort => 1)
      @p5 = com.products.create(:sort => 0)
      com.customers[0].purchases.create(:product => @p1)
      com.customers[0].purchases.create(:product => @p2)
      com.customers[0].purchases.create(:product => @p3)
      com.customers[0].purchases.create(:product => @p4)
      com.customers[0].purchases.create(:product => @p2)
      @p  = com.purchased_products
      @po = @p.order('products.id')
    end
    context "batches_by_range" do
      should("divisible") { assert_equal [[@p1, @p2], [@p3, @p4]], [].tap { |a| @po.batches_by_range(2) { |r| a << r } } }
      should("noneven")   { assert_equal [[@p1, @p2, @p3], [@p4]], [].tap { |a| @po.batches_by_range(3) { |r| a << r } } }
      should("offset")    { assert_equal [[@p2, @p3], [@p4]], [].tap { |a| @po.offset(1).batches_by_range(2) { |r| a << r } } }
      should("limit")     { assert_equal [[@p1, @p2], [@p3]], [].tap { |a| @po.limit(3).batches_by_range(2) { |r| a << r } } }
      should("ordered")   { assert_equal [[@p4, @p3], [@p2, @p1]], [].tap { |a| @p.order('products.sort').batches_by_range(2) { |r| a << r } } }
    end
    context "batches_by_ids" do
      should("divisible") { assert_equal [[@p1, @p2], [@p3, @p4]], [].tap { |a| @po.batches_by_ids(2) { |r| a << r } } }
      should("noneven")   { assert_equal [[@p1, @p2, @p3], [@p4]], [].tap { |a| @po.batches_by_ids(3) { |r| a << r } } }
      should("offset")    { assert_equal [[@p2, @p3], [@p4]], [].tap { |a| @po.offset(1).batches_by_ids(2) { |r| a << r } } }
      should("limit")     { assert_equal [[@p1, @p2], [@p3]], [].tap { |a| @po.limit(3).batches_by_ids(2) { |r| a << r } } }
      should("ordered")   { assert_equal [[@p4, @p3], [@p2, @p1]], [].tap { |a| @p.order('products.sort').batches_by_ids(2) { |r| a << r } } }
    end
    context "each_by_range" do
      should("divisible") { assert_equal [@p1, @p2, @p3, @p4], [].tap { |a| @po.each_by_range(2) { |r| a << r } } }
      should("noneven")   { assert_equal [@p1, @p2, @p3, @p4], [].tap { |a| @po.each_by_range(3) { |r| a << r } } }
      should("offset")    { assert_equal [@p2, @p3, @p4], [].tap { |a| @po.offset(1).each_by_range(2) { |r| a << r } } }
      should("limit")     { assert_equal [@p1, @p2, @p3], [].tap { |a| @po.limit(3).each_by_range(2) { |r| a << r } } }
      should("ordered")   { assert_equal [@p4, @p3, @p2, @p1], [].tap { |a| @p.order('products.sort').each_by_range(2) { |r| a << r } } }
    end
    context "each_by_ids" do
      should("divisible") { assert_equal [@p1, @p2, @p3, @p4], [].tap { |a| @po.each_by_ids(2) { |r| a << r } } }
      should("noneven")   { assert_equal [@p1, @p2, @p3, @p4], [].tap { |a| @po.each_by_ids(3) { |r| a << r } } }
      should("offset")    { assert_equal [@p2, @p3, @p4], [].tap { |a| @po.offset(1).each_by_ids(2) { |r| a << r } } }
      should("limit")     { assert_equal [@p1, @p2, @p3], [].tap { |a| @po.limit(3).each_by_ids(2) { |r| a << r } } }
      should("ordered")   { assert_equal [@p4, @p3, @p2, @p1], [].tap { |a| @p.order('products.sort').each_by_ids(2) { |r| a << r } } }
    end
  end
  
  # TODO: any more complicated queries?
end
