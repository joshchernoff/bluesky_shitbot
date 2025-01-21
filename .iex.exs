alias BsShitbot.BlueskyClient.Lists

email = BsShitbot.config([:blue_sky, :email])
pass = BsShitbot.config([:blue_sky, :pass])
shitlist_uri = "at://did:plc:4nd2nxnptle7cdq3thxtsqe6/app.bsky.graph.list/3lfikbvo2n52b"

jwt_fn = fn creds ->
  BsShitbot.JWTS.authenticate_with_email(
    Map.get(creds, :pass, email),
    Map.get(creds, :pass, pass)
  )
end

ident_resolver_fn = fn id -> BsShitbot.BlueskyClient.IdentResolver.resolve_did(id) end
get_profile_fn = fn did -> BsShitbot.BlueskyClient.IdentResolver.get_profiles([did]) end

process_dids_fn = fn dids ->
  Enum.chunk_every(dids, 20) |> BsShitbot.DidProducer.process_dids()
end

block_handle_fn = fn handle ->
  {:ok, did} = ident_resolver_fn.(handle)
  process_dids_fn.([did])
end

walk_list = fn fnc, token, cursor ->
  {:ok, %{"cursor" => cursor, "items" => items}} =
    Lists.get_list(
      token,
      "at://did:plc:4nd2nxnptle7cdq3thxtsqe6/app.bsky.graph.list/3lfikbvo2n52b",
      cursor
    )

  IO.inspect(cursor, label: :cursor)

  items
  |> Enum.each(fn %{"subject" => %{"did" => did, "handle" => handle}, "uri" => uri} = item ->
    BsShitbot.BlockedAccounts.create_blocked_account(%{
      "avatar" => Map.get(item, "avatar", nil),
      "did" => did,
      "display_name" => Map.get(item, "displayName", nil),
      "handle" => handle,
      "uri" => uri
    })
  end)

  :timer.sleep(300)
  fnc.(fnc, token, cursor)
end
