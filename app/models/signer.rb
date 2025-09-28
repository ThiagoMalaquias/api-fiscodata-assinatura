class Signer < ApplicationRecord
  has_one_attached :signature

  belongs_to :document
  store_accessor :variables

  after_update :verify_signatures, if: :saved_change_to_status?

  scope :pending, -> { where(status: "pending") }

  def send_document_to_signer
    EmailsMailer.send_document_to_signer(self).deliver
  end

  def set_variable(key, value)
    self.variables = variables.merge(key.to_s => value)
  end

  def get_variable(key)
    variables[key.to_s]
  end

  def populate_variables_from_template
    return if template.variables.blank?

    template.variables.each do |variable|
      set_variable(variable, nil) unless variables.key?(variable)
    end
  end

  private

  def verify_signatures
    signers_pending = document.signers.where(status: "pending")
    document.update(status: "completed") if signers_pending.count.zero?
  end
end