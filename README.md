# Slurper

Slurps data from different places.

- Covalenthq for historic event log data. Uses Elixir to query APIs
- On-chain data via Nodejs + Ethers.js for circulating supply

Pushes static data in `out/` to netlify site api.teddy.cash via netlify-cli.

## Setup

On a VM install asdf with asdf plugin for node, yarn, elixir, erlang.

```
# install netlify-cli
yarn install
netlify login
netlify site (just api.teddy.cash)

# setup elixir
cd elixir
asdf install
mix deps.get

# setup node
cd node
yarn install
```

Then update the static data:

```
# in this order..
# out/v1/circulating-supply
# - is read out by elixir to generate final report.
# - is used by coingecko to update circulating supply

# Generate circulating supply:
cd node
node src/circulating-supply.js > out/v1/circulating-supply

cd elixir
mix teddy.apr
# updates out/data.json
```

Then deploy to netlify:

```
netlify deploy --dir=out/ --prod
```
