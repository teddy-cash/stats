defmodule Reducer do
  require Logger

  @signature "LUSDBorrowingFeePaid(indexed address _borrower, uint256 _LUSDFee)"

  def write do
    {last_7d, total} = run()
    str = Jason.encode!(%{
      teddy_staking: %{
        last_7d_yield: trunc(last_7d),
        since_inception: trunc(total)
      }
    }, pretty: true)
    File.write!("out/data.json", str)
  end

  def run do
    fees = []

    lines = File.read!("activepool.json")
    |> String.split("\n")

    fees = Enum.reduce(lines, fees ,fn(line, acc) ->
      case Jason.decode(line) do
        {:ok, data} ->
          ts = data["block_signed_at"]
          if data["decoded"]["signature"] == @signature do
            [_from, %{"value" => val}] = data["decoded"]["params"]
            val = val |> String.to_integer()
            val = val / :math.pow(10, 18)
            if val > 0 do
              acc ++ [%{
                ts: data["block_signed_at"],
                fee: val
              }]
            else
              acc
            end
          else
            acc
          end

        _ ->
          acc
      end
    end)

    from = DateTime.utc_now() |> DateTime.add(-7*24*60*60, :second)
    last_7d = Enum.filter(fees, fn(%{ts: ts}) ->
      {:ok, dt, _} = DateTime.from_iso8601(ts)
      DateTime.compare(from, dt) == :lt
    end)
    |> Enum.reduce( 0, fn(%{fee: f}, acc) -> acc + f end)

    total = Enum.reduce(fees, 0, fn(%{fee: f}, acc) -> acc + f end)

    Enum.group_by(fees, fn(f) -> String.split(f.ts, "T") |> hd end, fn(f) -> f.fee end)
    |> Enum.sort_by(fn({ts, fees}) -> ts end)
    |> Enum.each(fn({ts, fees}) -> IO.puts("#{ts},#{Enum.sum(fees) |> trunc}") end)

    IO.puts("Last 7d: #{last_7d |> trunc}")
    IO.puts("Total: #{total |> trunc}")

    {last_7d, total}
  end
end
