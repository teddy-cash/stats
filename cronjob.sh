#!/bin/sh

(cd node/ && node src/circulating-supply.js > ../out/v1/circulating-supply)
(cd elixir/ && mix teddy.stats)
npx netlify deploy --dir=out/ --prod