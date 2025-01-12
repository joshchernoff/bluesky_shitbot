defmodule BsShitbot.Client.Bluesky do
  @url "https://bsky.social/xrpc/com.atproto.server.createSession"
  @refresh_session_url "https://bsky.social/xrpc/com.atproto.server.refreshSession"

  @doc """
  This function will do list of procedures to get a valid jwt
  If at first it finds a non exspired jwt it will return that.
  If required it will refresh the jwt with a non expired refresh token
  If all the above fails it will also try to create a whole new set of jwts for a user

  The first argument is a look up function used to fetch a given user.
  The second argument is a upsirt function used to upsirt new set of jwts for a given user
  The third argument is a username used to look up a given user and or to create a new set of jwts
  the fourth argument is a password user to create a new set of jwts if required
  """
  def authenticate(lookup_fn, upsirt_fn, username, password) do
    username
    |> lookup_fn.()
    |> handle_lookup()
    |> Enum.find(fn jwt -> jws_current?(jwt) end)
    |> maybe_refresh_jwt()
    |> maybe_upsirt_jwt(upsirt_fn, username, password)
  end

  # api call for creating new jwt
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

  # api call for refreshing jwt
  def refresh_auth_token(refresh_token) do
    case Req.post(
           @refresh_session_url,
           json: %{
             "refresh_token" => refresh_token
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

  # Found user
  defp handle_lookup({:ok, %{access_jwt: access_jwt, refresh_jwt: refresh_jwt}}),
    do: %{access_jwt: access_jwt, refresh_jwt: refresh_jwt}

  # No user was found
  defp handle_lookup(_) do
    nil
  end

  # Return current jwt
  defp maybe_refresh_jwt(%{access_jwt: access_jwt}), do: {:ok, %{access_jwt: access_jwt}}

  # Return refresh jwt
  defp maybe_refresh_jwt(%{refesh_jwt: refesh_jwt}), do: refresh_auth_token(refesh_jwt)

  # Could not find jwt
  defp maybe_refresh_jwt(nil), do: nil

  # given we already have current jwt
  defp maybe_upsirt_jwt(%{access_jwt: access_jwt}, _, _, _), do: access_jwt

  # given we had to refresh auth
  defp maybe_upsirt_jwt({:ok, payload}, upsirt_fn, _, _) do
    upsirt_fn.(payload)
    # return jwt
  end

  # given we need new jwt
  defp maybe_upsirt_jwt(nil, upsirt_fn, username, password) do
    case create_auth_token(username, password) do
      {:ok, body} ->
        # save and return
        upsirt_fn.(body)
        # return jwt
    end
  end

  # Is it exspired?
  defp jws_current?(jwt) do
    jwt
    |> decode_jwt_payload()
    |> case do
      %{
        "exp" => exp
      } ->
        ct =
          "Etc/UTC"
          |> DateTime.now!()
          |> DateTime.add(30 * 60)
          |> DateTime.to_unix()

        ct < exp
    end
  end

  # What is in the jwt's payload
  defp decode_jwt_payload(jwt) do
    [_, payload, _] = String.split(jwt, ".")

    payload
    |> Base.url_decode64!(padding: false)
    |> Jason.decode!()
  end
end
