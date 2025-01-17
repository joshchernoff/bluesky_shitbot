defmodule BsShitbot.BlueskyClient.Auth do
  @url "https://bsky.social/xrpc/com.atproto.server"

  @doc """
  Authenticates via a email and password then saves/upsirts the jwt for reuse

  This function will do a list of procedures in order to return a valid jwt

  If at first it finds a non expired access jwt it will return that.
  If required it will refresh the jwt with a non expired refresh jwt
  If all the above fails it will then try to create a whole new set of jwts for given email and password

  The first argument is a look up function used to fetch a given user.
  The second argument is a upsirt function used to upsirt new set of jwts for a given user
  The third argument is a email used to look up a given user and or to create a new set of jwts
  the fourth argument is a password user to create a new set of jwts if required
  """
  def authenticate(
        lookup_by_email_fn,
        upsirt_by_email_fn,
        email,
        password,
        create_auth_token_fn \\ &create_auth_token/2,
        refresh_auth_token_fn \\ &refresh_auth_token/1
      ) do
    email
    |> lookup_by_email_fn.()
    |> handle_lookup()
    |> check_expired()
    # |> Enum.find(fn jwt -> !jws_expired?(jwt) end)
    |> maybe_refresh_jwt(refresh_auth_token_fn)
    |> maybe_upsirt_jwt(upsirt_by_email_fn, email, password, create_auth_token_fn)
  end

  @doc """
  Creates a new jwt.
  """
  def create_auth_token(email, password) do
    case Req.post(
           @url <> ".createSession",
           json: %{
             "identifier" => email,
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

  @doc """
  Create a new jws from a refreshing jwt
  """
  def refresh_auth_token(refresh_token) do
    headers = [
      {"Authorization", "Bearer #{refresh_token}"}
    ]

    case Req.post(@url <> ".refreshSession", headers: headers) do
      {:ok, %{status: 200, body: response}} ->
        {:ok, response}

      {:ok, %{status: status, body: response}} ->
        {:error, "Request failed with status #{status}: #{inspect(response)}"}

      {:error, reason} ->
        {:error, "Request failed: #{inspect(reason)}"}
    end
  end

  # Found user
  defp handle_lookup([jwt]), do: jwt
  # No user was found
  defp handle_lookup(_), do: nil

  defp check_expired(nil), do: nil

  defp check_expired(%{access_jwt: access_jwt} = jwt) do
    if jws_expired?(access_jwt) do
      check_expired({:check_refresh, jwt})
    else
      jwt
    end
  end

  defp check_expired({:check_refresh, %{refresh_jwt: refresh_jwt} = jwt}) do
    if jws_expired?(refresh_jwt) do
      check_expired(nil)
    else
      {:need_refreshed, jwt}
    end
  end

  # Return current jwt
  defp maybe_refresh_jwt(%{access_jwt: _access_jwt} = jwt, _), do: {:ok, jwt}

  # Return refresh jwt
  defp maybe_refresh_jwt(
         {:need_refreshed, %{refresh_jwt: refresh_jwt}},
         refresh_auth_token_fn
       ) do
    refresh_auth_token_fn.(refresh_jwt)
  end

  # Could not find jwt
  defp maybe_refresh_jwt(nil, _), do: nil

  # given we already have current jwt
  defp maybe_upsirt_jwt({:ok, %{access_jwt: _access_jwt} = jwt}, _, _, _, _), do: jwt

  # given we had to refresh auth
  defp maybe_upsirt_jwt(
         {:ok,
          %{
            "accessJwt" => access_jwt,
            "refreshJwt" => refresh_jwt,
            "handle" => handle,
            "did" => did
          }},
         upsirt_fn,
         email,
         _,
         _
       ) do
    case upsirt_fn.(%{
           access_jwt: access_jwt,
           refresh_jwt: refresh_jwt,
           email: email,
           handle: handle,
           did: did
         }) do
      {:ok, jwt} -> jwt
    end
  end

  # given we need new jwt
  defp maybe_upsirt_jwt(nil, upsirt_fn, email, password, create_auth_token_fn) do
    case create_auth_token_fn.(email, password) do
      {:ok,
       %{
         "accessJwt" => access_jwt,
         "refreshJwt" => refresh_jwt,
         "email" => email,
         "handle" => handle,
         "did" => did
       }} ->
        case upsirt_fn.(%{
               access_jwt: access_jwt,
               refresh_jwt: refresh_jwt,
               email: email,
               handle: handle,
               did: did
             }) do
          {:ok, jwt} -> jwt
        end
    end
  end

  defp jws_expired?(jwt) do
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

        ct >= exp
    end
  end

  defp decode_jwt_payload(jwt) do
    [_, payload, _] = String.split(jwt, ".")

    payload
    |> Base.url_decode64!(padding: false)
    |> Jason.decode!()
  end
end
