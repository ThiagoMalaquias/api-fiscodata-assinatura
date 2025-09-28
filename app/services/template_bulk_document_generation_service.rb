class TemplateBulkDocumentGenerationService
  def initialize(template, template_users)
    @template = template
    @template_users = template_users
  end

  def call
    results = []
    
    @template_users.each do |template_user|
      service = DocumentGenerationFromTemplateService.new(template_user)
      document = service.call
      
      results << {
        template_user: template_user,
        document: document,
        success: true
      }
    rescue => e
      results << {
        template_user: template_user,
        error: e.message,
        success: false
      }
    end
    
    results
  end
end