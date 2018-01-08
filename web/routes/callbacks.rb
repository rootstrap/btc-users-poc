module Routes
  class Callbacks < Cuba
    define do
      verify_api_key!(env['HTTP_API_KEY'])

      on('btc') do
        on(':txid') do |txid|
          on(post) do
            Workers::Bitcoin::Transaction.perform_async(txid)
            res.status = 204
          end
        end
      end
    end
  end
end
