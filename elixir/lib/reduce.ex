defmodule Reducer do
  require Logger

  def write do
    {borrowing_7d, borrowing_total} = run()

    {redemption_7d, redemption_total} = redemption()

    str = Jason.encode!(%{
      updated_at: DateTime.utc_now(),
      borrowing_fee_tsd: %{
        last_7d_yield: borrowing_7d,
        since_inception: borrowing_total
      },
      redemption_fee_avax: %{
        last_7d_yield: redemption_7d,
        since_inception: redemption_total
      }
    }, pretty: true)
    File.write!("../out/data.json", str)
  end

  def run do
    signature = "LUSDBorrowingFeePaid(indexed address _borrower, uint256 _LUSDFee)"
    fees = []

    lines = File.read!("activepool.json")
    |> String.split("\n")

    fees = Enum.reduce(lines, fees ,fn(line, acc) ->
      case Jason.decode(line) do
        {:ok, data} ->
          ts = data["block_signed_at"]
          if data["decoded"]["signature"] == signature do
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


  def redemption do
    signature = "Redemption(uint256 _attemptedLUSDAmount, uint256 _actualLUSDAmount, uint256 _ETHSent, uint256 _ETHFee)"
    fees = []

    lines = File.read!("trovemanager.json")
    |> String.split("\n")

    fees = Enum.reduce(lines, fees ,fn(line, acc) ->
      case Jason.decode(line) do
        {:ok, data} ->
          ts = data["block_signed_at"]
          if data["decoded"]["signature"] == signature do
            [_, _, _, %{"value" => val}] = data["decoded"]["params"]
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

    IO.puts("Last 7d: #{last_7d}")
    IO.puts("Total: #{total}")

    {last_7d, total}
  end
end
