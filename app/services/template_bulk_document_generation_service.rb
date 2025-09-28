class TemplateBulkDocumentGenerationService
  def initialize(template, users, current_user)
    @template = template
    @users = users
    @current_user = current_user
  end

  def call
    results = []
  
    @users.each do |user|
      document = DocumentGenerationFromTemplateService.new(@template, user, @current_user).call
 
      results << {
        user: user,
        document: document,
        success: true
      }
    rescue => e
      results << {
        user: user,
        error: e.message,
        success: false
      }
    end
    
    results
  end
end