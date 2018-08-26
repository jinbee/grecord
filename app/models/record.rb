class Record < ApplicationRecord

    validates :outgo,presence: true , numericality: true
    validates :count,presence: true , numericality: true
    validates :purpose, length:{maximum: 200}
    validates :routine, length:{maximum: 200}
    belongs_to :user
    belongs_to :sgame
end
