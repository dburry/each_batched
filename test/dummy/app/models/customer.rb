
class Customer < ActiveRecord::Base
  belongs_to :company
  has_many :purchases
  has_many :purchased_products, :through => :purchases, :source => :products, :uniq => true
end
