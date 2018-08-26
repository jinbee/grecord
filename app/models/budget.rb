class Budget < ApplicationRecord

    validates :month,presence: true , numericality: true, format: { with: /\A(\d{4})(0[1-9]|1[0-2])\z/i }
    validates :budget,presence: true , numericality: true
    belongs_to :user
end
