
class InitializeModels < ActiveRecord::Migration
  def self.up
    create_table :companies do |t|
      t.integer    :sort,       :null => false, :default => 0
    end
    create_table :customers do |t|
      t.integer    :sort ,      :null => false, :default => 0
      t.references :company,    :null => false
    end
    create_table :products do |t|
      t.integer    :sort,       :null => false, :default => 0
      t.references :company,    :null => false
    end
    create_table :purchases do |t|
      t.date       :ordered_on, :null => false, :default => Date.parse('Jan 1 2011')
      t.references :product,    :null => false
      t.references :customer,   :null => false
    end
    add_index :companies, :sort
    add_index :customers, :sort
    add_index :customers, :company_id
    add_index :products,  :sort
    add_index :products,  :company_id
    add_index :purchases, :ordered_on
    add_index :purchases, :product_id
    add_index :purchases, :customer_id
  end
  
  def self.down
    drop_table :purchases
    drop_table :products
    drop_table :customers
    drop_table :companies
  end
end
