defmodule BsShitbot.JWTSFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `BsShitbot.JWTS` context.
  """

  @doc """
  Generate a jwt.
  """
  def jwt_fixture(attrs \\ %{}) do
    {:ok, jwt} =
      attrs
      |> Enum.into(%{
        access_jwt: "some access_jwt",
        email: "some email",
        handle: "some handle",
        refresh_jwt: "some refresh_jwt"
      })
      |> BsShitbot.JWTS.create_jwt()

    jwt
  end
end
