class AwsService
  AWS_ID = Rails.application.credentials.dig(:aws, :access_key_id)
  AWS_KEY = Rails.application.credentials.dig(:aws, :secret_access_key)
  BUCKET  = 'ead-rani-passos'.freeze

  def self.s3
    Aws::S3::Resource.new(
      credentials: Aws::Credentials.new(AWS_ID, AWS_KEY),
      region: 'sa-east-1'
    )
  end

  def self.upload(file, name)
    obj = s3.bucket(BUCKET).object("#{Time.now.to_i}-#{name}")
    
    # Determina o content_type baseado na extensão do arquivo
    content_type = case File.extname(name).downcase
                   when '.pdf' then 'application/pdf'
                   when '.doc', '.docx' then 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
                   when '.jpg', '.jpeg' then 'image/jpeg'
                   when '.png' then 'image/png'
                   else 'application/octet-stream'
                   end
    
    obj.upload_file(
      file,
      acl: 'public-read',
      content_type: content_type,
      metadata: {
        'Content-Disposition' => 'inline'
      }
    )
    
    obj.public_url
  end

  def self.delete(path_file)
    bucket = s3.bucket(BUCKET)
    bucket.objects.each do |file|
      file.delete if file.key == File.basename(path_file)
    end
  end

  def self.get(path_file)
    s3.bucket(BUCKET).object(path_file).get.body.read
  end
end
