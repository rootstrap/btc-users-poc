RSpec.describe Services::BitcoinDeposits::UserDeposits do
  subject(:service) { Services::BitcoinDeposits::UserDeposits }

  describe '.perform' do
    let(:user) { Fabricate(:user) }

    subject(:perform) { service.perform(user) }

    context 'when user made no deposits' do
      it { is_expected.to eq([]) }
    end

    context 'when user made two deposits' do
      #
    end

    context 'when other users made deposits' do
      context 'when user made two deposits' do
        #
      end

      context 'when user made no deposits' do
        it { is_expected.to eq([]) }
      end
    end
  end
end
