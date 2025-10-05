class Api::V1::User::TemplateFoldersController < Api::V1::User::ApplicationController
  before_action :set_template_folder, only: [:show, :update, :destroy, :move_to_back_folder, :move_to_folder]

  def index
    @template_folders = @current_user.template_folders.where(origin_id: nil).order(created_at: :desc)
  end

  def move_to_folder
    @template_folder.update(origin_id: params[:template_folder][:origin_id], origin_type: "TemplateFolder")
    render json: { message: "Template movido para a pasta" }, status: :ok
  end
  
  def move_to_back_folder
    @template_folder.update(origin: @template_folder.origin.origin)
    render json: { message: "Pasta movida para a pasta anterior" }, status: :ok
  end

  def create
    @folder = @current_user.template_folders.new(name: params[:template_folder][:name])
    @folder.user = @current_user

    if params[:template_folder][:origin_id].present?
      @folder.origin_id = params[:template_folder][:origin_id]
      @folder.origin_type = "TemplateFolder"
    end

    @folder.save

    if @folder.save
      render json: @folder, status: :created
    else
      render json: @folder.errors, status: :unprocessable_entity
    end
  end

  def update
    if @template_folder.update(template_folder_params)
      render json: @template_folder
    else
      render json: @template_folder.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @template_folder.destroy
    head :no_content
  end

  private

  def set_template_folder
    @template_folder = @current_user.template_folders.find(params[:id])
  end

  def template_folder_params
    params.require(:template_folder).permit(:name)
  end
end