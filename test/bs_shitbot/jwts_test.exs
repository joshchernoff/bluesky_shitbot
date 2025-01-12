defmodule BsShitbot.JWTSTest do
  use BsShitbot.DataCase

  alias BsShitbot.JWTS

  describe "jwts" do
    alias BsShitbot.JWTS.JWT

    import BsShitbot.JWTSFixtures

    @invalid_attrs %{handle: nil, email: nil, access_jwt: nil, refresh_jwt: nil}

    test "list_jwts/0 returns all jwts" do
      jwt = jwt_fixture()
      assert JWTS.list_jwts() == [jwt]
    end

    test "get_jwt!/1 returns the jwt with given id" do
      jwt = jwt_fixture()
      assert JWTS.get_jwt!(jwt.id) == jwt
    end

    test "create_jwt/1 with valid data creates a jwt" do
      valid_attrs = %{handle: "some handle", email: "some email", access_jwt: "some access_jwt", refresh_jwt: "some refresh_jwt"}

      assert {:ok, %JWT{} = jwt} = JWTS.create_jwt(valid_attrs)
      assert jwt.handle == "some handle"
      assert jwt.email == "some email"
      assert jwt.access_jwt == "some access_jwt"
      assert jwt.refresh_jwt == "some refresh_jwt"
    end

    test "create_jwt/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = JWTS.create_jwt(@invalid_attrs)
    end

    test "update_jwt/2 with valid data updates the jwt" do
      jwt = jwt_fixture()
      update_attrs = %{handle: "some updated handle", email: "some updated email", access_jwt: "some updated access_jwt", refresh_jwt: "some updated refresh_jwt"}

      assert {:ok, %JWT{} = jwt} = JWTS.update_jwt(jwt, update_attrs)
      assert jwt.handle == "some updated handle"
      assert jwt.email == "some updated email"
      assert jwt.access_jwt == "some updated access_jwt"
      assert jwt.refresh_jwt == "some updated refresh_jwt"
    end

    test "update_jwt/2 with invalid data returns error changeset" do
      jwt = jwt_fixture()
      assert {:error, %Ecto.Changeset{}} = JWTS.update_jwt(jwt, @invalid_attrs)
      assert jwt == JWTS.get_jwt!(jwt.id)
    end

    test "delete_jwt/1 deletes the jwt" do
      jwt = jwt_fixture()
      assert {:ok, %JWT{}} = JWTS.delete_jwt(jwt)
      assert_raise Ecto.NoResultsError, fn -> JWTS.get_jwt!(jwt.id) end
    end

    test "change_jwt/1 returns a jwt changeset" do
      jwt = jwt_fixture()
      assert %Ecto.Changeset{} = JWTS.change_jwt(jwt)
    end
  end
end
