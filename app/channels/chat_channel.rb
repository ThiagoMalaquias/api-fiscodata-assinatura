class ChatChannel < ApplicationCable::Channel
  def subscribed
    # Código que é executado quando o cliente se inscreve no canal
    stream_from "chat_channel"
  end

  def unsubscribed
    # Qualquer limpeza necessária quando o cliente se desinscrever
  end

  # Outros métodos para lidar com ações específicas do cliente
end
