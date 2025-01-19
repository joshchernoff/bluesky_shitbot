defmodule ComAtprotoRepo do
  @moduledoc """
  Simple Elixir module for interacting with the com.atproto.repo.listRecords endpoint.
  """

  @base_url "https://bsky.social/xrpc/com.atproto.repo.listRecords"

  def list_records(repo, collection, opts \\ []) do
    params =
      opts
      |> Keyword.merge(repo: repo, collection: collection)
      |> Enum.reject(fn {_k, v} -> is_nil(v) end)

    Req.get!(@base_url, params: params)
    |> handle_response()
  end

  defp handle_response(%Req.Response{status: 200, body: body}), do: {:ok, body}

  defp handle_response(%Req.Response{status: status, body: body}),
    do: {:error, %{status: status, body: body}}
end
