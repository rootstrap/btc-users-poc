RSpec.describe Services::Bitcoin::CreateDepositAddress do
  subject(:service) { Services::Bitcoin::CreateDepositAddress }

  describe '.perform' do
    let(:client) { double(:client) }
    let(:address) { 'an-address' }
    let(:user) { Fabricate(:user) }

    subject(:perform) { service.perform(user) }

    before do
      allow(Services::Bitcoin::GetClient)
        .to receive(:perform)
        .and_return(client)

      allow(client)
        .to receive(:execute)
        .with('getnewaddress')
        .and_return('result' => address)
    end

    it 'creates the deposit address' do
      expect {
        perform
      }.to change(BitcoinDepositAddress, :count).by(1)
    end
  end
end
