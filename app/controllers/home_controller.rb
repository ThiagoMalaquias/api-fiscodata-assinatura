class HomeController < ApplicationController
  def index
    render json: { message: "Bem vindo a API de assinatura" }
  end
end