defmodule BsShitbot.Client.Bluesky do
  @url "https://bsky.social/xrpc/com.atproto.server.createSession"

  def create_auth_token(username, password) do
    case Req.post(
           @url,
           json: %{
             "identifier" => username,
             "password" => password
           }
         ) do
      {:ok, %{status: 200, body: response}} ->
        {:ok, response}

      {:ok, %{status: status, body: response}} ->
        {:error, "Request failed with status #{status}: #{inspect(response)}"}

      {:error, reason} ->
        {:error, "Request failed: #{inspect(reason)}"}
    end
  end
end
