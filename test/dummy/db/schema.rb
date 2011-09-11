# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 1) do

  create_table "companies", :force => true do |t|
    t.integer "sort", :default => 0, :null => false
  end

  add_index "companies", ["sort"], :name => "index_companies_on_sort"

  create_table "customers", :force => true do |t|
    t.integer "sort",       :default => 0, :null => false
    t.integer "company_id",                :null => false
  end

  add_index "customers", ["company_id"], :name => "index_customers_on_company_id"
  add_index "customers", ["sort"], :name => "index_customers_on_sort"

  create_table "products", :force => true do |t|
    t.integer "sort",       :default => 0, :null => false
    t.integer "company_id",                :null => false
  end

  add_index "products", ["company_id"], :name => "index_products_on_company_id"
  add_index "products", ["sort"], :name => "index_products_on_sort"

  create_table "purchases", :force => true do |t|
    t.date    "ordered_on",  :default => '2011-01-01', :null => false
    t.integer "product_id",                            :null => false
    t.integer "customer_id",                           :null => false
  end

  add_index "purchases", ["customer_id"], :name => "index_purchases_on_customer_id"
  add_index "purchases", ["ordered_on"], :name => "index_purchases_on_ordered_on"
  add_index "purchases", ["product_id"], :name => "index_purchases_on_product_id"

end
