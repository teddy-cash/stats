defmodule Covalent do
  use Tesla

  adapter Tesla.Adapter.Hackney, [recv_timeout: 30_000]

  plug Tesla.Middleware.Timeout, timeout: 30_000
  plug Tesla.Middleware.BaseUrl, "https://api.covalenthq.com/v1/43114/"
  plug Tesla.Middleware.JSON
  plug Tesla.Middleware.BasicAuth, username: "ckey_37c5ada58ffe43f9b5e6997725d", password: ""

end


# events/address/0x094bd7B2D99711A1486FB94d4395801C6d0fdDcC/\?starting-block\=3495967\&ending-block\=latest    -u ckey_37c5ada58ffe43f9b5e6997725d:
