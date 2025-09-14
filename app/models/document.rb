class Document < ApplicationRecord
  has_one_attached :file
  
  belongs_to :user
  has_many :signers, dependent: :destroy
  has_one :reviewer, dependent: :destroy

  enum status: {
    draft: "draft",
    pending: "pending",
    completed: "completed"
  }

  validates :name, presence: true
  validates :file, presence: true
  validates :description, presence: true
end
