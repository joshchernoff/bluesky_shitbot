defmodule BsShitbot.JWTS do
  @moduledoc """
  The JWTS context.
  """

  import Ecto.Query, warn: false
  alias BsShitbot.Client.Bluesky
  alias BsShitbot.Repo
  alias BsShitbot.JWTS.JWT

  @doc """
  Returns the list of jwts.

  ## Examples

      iex> list_jwts()
      [%JWT{}, ...]

  """
  def list_jwts do
    Repo.all(JWT)
  end

  def authenticate_with_email(email, password) do
    Bluesky.authenticate(&get_jwt_by_email!/1, &upsirt_jwt_by_email/2, email, password)
  end

  @doc """
  Gets a single jwt.

  Raises `Ecto.NoResultsError` if the Jwt does not exist.

  ## Examples

      iex> get_jwt!(123)
      %JWT{}

      iex> get_jwt!(456)
      ** (Ecto.NoResultsError)

  """
  def get_jwt!(id), do: Repo.get!(JWT, id)

  def get_jwt_by_email!(email) do
    Repo.get_by!(JWT, %{email: email})
  end

  @doc """
  Creates a jwt.

  ## Examples

      iex> create_jwt(%{field: value})
      {:ok, %JWT{}}

      iex> create_jwt(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_jwt(attrs \\ %{}) do
    %JWT{}
    |> JWT.changeset(attrs)
    |> Repo.insert()
  end

  def upsirt_jwt_by_email(email, attrs) do
    case from(jwt in JWT, where: jwt.email == ^email) |> Repo.one() do
      {:ok, jwt} ->
        update_jwt(jwt, attrs)

      _ ->
        create_jwt(attrs)
    end
  end

  @doc """
  Updates a jwt.

  ## Examples

      iex> update_jwt(jwt, %{field: new_value})
      {:ok, %JWT{}}

      iex> update_jwt(jwt, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_jwt(%JWT{} = jwt, attrs) do
    jwt
    |> JWT.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a jwt.

  ## Examples

      iex> delete_jwt(jwt)
      {:ok, %JWT{}}

      iex> delete_jwt(jwt)
      {:error, %Ecto.Changeset{}}

  """
  def delete_jwt(%JWT{} = jwt) do
    Repo.delete(jwt)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking jwt changes.

  ## Examples

      iex> change_jwt(jwt)
      %Ecto.Changeset{data: %JWT{}}

  """
  def change_jwt(%JWT{} = jwt, attrs \\ %{}) do
    JWT.changeset(jwt, attrs)
  end
end
