class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product

  validates :order_id, presence: true
  validates :product_id, presence: true, uniqueness: { scope: :order_id }
  validates :quantity, presence: true, numericality: { greater_than_or_equal_to: 1 }
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
end