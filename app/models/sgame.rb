class Sgame < ApplicationRecord
    validates :gname,presence: true , length:{maximum: 32}
    belongs_to :user
    has_many :records , dependent: :destroy
end
