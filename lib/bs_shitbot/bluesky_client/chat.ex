defmodule BsShitbot.BlueskyClient.Chat do
  def send_message(token, service_endpoint, convo_id, message) do
    url =
      "#{service_endpoint}/xrpc/chat.bsky.convo.sendMessage"

    headers =
      [
        {"Authorization", "Bearer #{token}"},
        {"Atproto-Proxy", "did:web:api.bsky.chat#bsky_chat"}
      ]

    body =
      %{
        "convoId" => convo_id,
        "message" => %{"text" => message}
      }

    case Req.post(url, headers: headers, json: body) do
      {:ok, %{status: 200, body: response_body}} ->
        {:ok, response_body}

      {:ok, %{status: status_code, body: error_body}} ->
        {:error, %{status: status_code, error: error_body}}

      {:error, reason} ->
        {:error, reason}
    end
  end
end
