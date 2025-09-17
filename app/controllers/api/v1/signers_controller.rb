class Api::V1::SignersController < Api::V1::ApplicationController
  before_action :set_signer

  def document
    if @signer.blank?
      render json: { error: "Signer not found" }, status: :not_found
    end
  end

  def sign
    if @signer.update(status: "signed", signature_at: Time.now)
      attach_avatar(@signer, params[:signer][:signature])

      render json: @signer.as_json(except: [:signature]), status: :ok
    else
      render json: @signer.errors, status: :unprocessable_entity
    end
  end

  def reject
    if @signer.update(status: "rejected", rejected_at: Time.now, rejection: params[:signer][:rejection])
      render json: @signer.as_json(except: [:signature]), status: :ok
    else
      render json: @signer.errors, status: :unprocessable_entity
    end
  end

  private

  def attach_avatar(signer, image = nil)
    require 'open-uri'

    avatar = image || params[:signer][:signature]
    return if avatar.blank?

    filename = signer.name.parameterize(separator: "_").downcase + Time.now.to_i.to_s

    if avatar.include?("data:")
      signer.signature.attach(io: decode_image(avatar), filename: "#{filename}.jpg")
      return
    end

    image_data = URI.open(avatar)
    signer.signature.attach(io: image_data, filename: "#{filename}.jpg")
  end

  def decode_image(data)
    base64_encoded_data = data.split(',')[1]
    decoded_data = Base64.decode64(base64_encoded_data)
    StringIO.new(decoded_data)
  end

  def set_signer
    @signer = Signer.find_by(code: params[:code])
  end
end