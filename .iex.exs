email = BsShitbot.config([:blue_sky, :email])
pass = BsShitbot.config([:blue_sky, :pass])

jwt_fn = fn creds ->
  BsShitbot.JWTS.authenticate_with_email(
    Map.get(creds, :pass, email),
    Map.get(creds, :pass, pass)
  )
end

ident_resolver_fn = fn id -> BsShitbot.BlueskyClient.IdentResolver.resolve_did(id) end

process_dids_fn = fn dids ->
  Enum.chunk_every(dids, 20) |> BsShitbot.DidProducer.process_dids()
end

block_handle_fn = fn handle ->
  {:ok, did} = ident_resolver_fn.(handle)
  process_dids_fn.([did])
end
