class TemplateUserBulkCreationService
  def initialize(template, users_data)
    @template = template
    @users_data = users_data
  end

  def call
    created_count = 0
    errors = []

    @users_data.each_with_index do |user_data, index|
      template_user = @template.template_signers.build(
        name: user_data[:name],
        email: user_data[:email],
        role: user_data[:role],
        variables: user_data[:variables] || {},
        code: SecureRandom.uuid
      )

      if template_user.save
        created_count += 1
      else
        errors << { index: index, errors: template_user.errors.full_messages }
      end
    end

    {
      success: errors.empty?,
      count: created_count,
      errors: errors
    }
  end
end