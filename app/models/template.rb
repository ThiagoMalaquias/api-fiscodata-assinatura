class Template < ApplicationRecord
  belongs_to :user
  has_many :documents, dependent: :destroy
  belongs_to :template_folder, optional: true

  validates :title, presence: true
  validates :content, presence: true

end