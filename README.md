# Roundup V5.4 Polished Market + Friend-Group Logic

This version focuses on the real app loop and a smoother stock market.

## Biggest changes
- Drink stock prices are trade-only: buys move price up, sells move price down.
- Drink logs create hype/volume context but do not automatically pump prices.
- Stock rows use smoother shared charts from `stock_ticks`.
- Drink rows use safer data attributes so names like `Tito's Soda` do not break buttons.
- Drink detail pages explain why a price moved.
- Group screens get a cleaner game-loop explanation.
- Portfolio tracking remains, with no break-even line.

## Upload instructions
Upload the files inside this folder to the root of your GitHub repo. Do not upload the ZIP itself.

Open your GitHub Pages link with `?v=54` after uploading.

## Supabase
Keep using the V5/V5.1 SQL files included here if you have not already run them. They are needed for shared stock ticks, transaction history, and group features.
