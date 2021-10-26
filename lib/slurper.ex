defmodule Slurper do
  require Logger

  @path "activepool.json"
  @first_block 3415967

  def slurp do
    file = File.read!(@path)
    lines = String.split(file, "\n", trim: true)
    last_line = List.last(lines)

    Logger.info(last_line)
    block = case last_line do
      nil ->
        @first_block
      str ->
        case Jason.decode(str) do
          {:ok, json} ->
            json["block_height"]
          _ ->
            @first_block
        end
    end

    Logger.info("block #{block}")

    slurp(block, 0, max_block_height())
  end

  def max_block_height() do
    resp = Covalent.get!("/block_v2/latest/")
    List.first(resp.body["data"]["items"])["height"]
  end


  def slurp(block_start, page, max_block_height) do
    block_end = block_start + 100_000

    %{body: %{"data" => data}} = Covalent.get!("/events/address/0xF582CAE047853cbe7F0Bc8f8321bEF4a1eBE0307/", query: %{
      "starting-block" => block_start,
      "ending-block" => block_end,
      "page-number" => page
    })

    for item <- data["items"] do
      File.write(@path, Jason.encode!(item) <> "\n", [:append])
    end

    Logger.info("Slurped page #{page} from block ##{block_start} - ##{block_end}")

    if data["pagination"]["has_more"] == nil && length(data["items"]) > 0 do
      slurp(block_start, page + 1, max_block_height)
    else
      if block_end > max_block_height do
        Logger.info("finished")
      else
        slurp(block_start + 100_000, 0, max_block_height)
      end
    end
  end
end
