module Helpers
  module BTCHelper
    def satoshi(amount)
      amount.to_f / 100_000_000
    end

    def btc(amount)
      "BTC #{satoshi(amount)}"
    end

    def dmc(amount)
      "DMC #{satoshi(amount)}"
    end
  end
end
