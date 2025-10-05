class TemplateFolder < ApplicationRecord
  belongs_to :user
  belongs_to :origin, polymorphic: true, optional: true
  has_many :templates, dependent: :destroy
  has_many :sub_folders, as: :origin, class_name: 'TemplateFolder', dependent: :destroy

  scope :root_folders, -> { where(origin_id: nil) }
end
