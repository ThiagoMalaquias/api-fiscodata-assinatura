class Document < ApplicationRecord
  has_one_attached :file
  
  belongs_to :user
  has_many :signers, dependent: :destroy
  has_one :reviewer, dependent: :destroy

  enum status: {
    draft: "draft",
    pending_review: "pending_review",
    pending_signature: "pending_signature",
    completed: "completed",
    rejected: "rejected"
  }

  validates :name, presence: true
  validates :file, presence: true
  validates :description, presence: true

  def requires_review?
    reviewer.present?
  end

  def ready_for_signatures?
    !requires_review? || reviewer&.approved?
  end
end