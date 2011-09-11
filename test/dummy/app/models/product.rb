
class Product < ActiveRecord::Base
  belongs_to :company
  has_many :purchases
end
