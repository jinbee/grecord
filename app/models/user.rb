class User < ApplicationRecord
    validates :name,presence: true , length:{maximum: 30}
    validates :email,presence: true, length:{maximum: 255} ,format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i } , uniqueness: true
    has_secure_password
    validates :password, presence: true, length: { minimum: 3 } ,on: :create,on: :editpw
    has_many :records , dependent: :destroy
    has_many :sgames, dependent: :destroy
    has_many :budgets, dependent: :destroy
end
