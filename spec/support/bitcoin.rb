require 'json'

module Support
  module Bitcoin
    def bitcoin_transaction(txid)
      path = File.join(File.dirname(__FILE__), "bitcoin", "#{txid}.json")
      JSON.parse(File.read(path))
    end
  end
end
