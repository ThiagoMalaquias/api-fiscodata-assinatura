class Template < ApplicationRecord
  belongs_to :user
  has_many :documents, dependent: :destroy

  validates :title, presence: true
  validates :content, presence: true
end