RSpec.describe Services::BitcoinDeposits::StoreDeposit do
  subject(:service) { Services::BitcoinDeposits::StoreDeposit }

  describe '.perform' do
    let(:transaction) { nil }
    subject(:perform) { service.perform(transaction) }

    context 'when transaction is valid' do
      let(:address) { 'mgC69fG5F5455zCUM9ppU1r85vo6raUWBP' }
      let(:txid) { '5d1b3bc52883f7b4da40293677e49bcc8703fdc0e70db9ae197ecf4dc90b08f2' }
      let(:transaction) { bitcoin_transaction(txid) }

      context 'when address does not exist' do
        it { will_expect.to_not change(BitcoinDeposit, :count) }
      end

      context 'when address exists' do
        let(:user) { Fabricate(:user) }

        let!(:deposit_address) do
          Fabricate(:bitcoin_deposit_address, address: address, user: user)
        end

        it { will_expect.to change(BitcoinDeposit, :count).by(1) }

        context 'when transaction has no confirmations' do
          subject(:perform) do
            service.perform(transaction.merge('confirmations' => 0))
          end

          it { will_expect.to change { deposit_address.reload.total } }
          it { will_expect.to change { user.reload.balance } }
          it { will_expect.to change { user.reload.unconfirmed_balance } }

          context 'when transaction comes again' do
            before { perform }

            let(:deposit) do
              BitcoinDeposit.where(txid: txid, index: 0).first
            end

            let(:second_perform) { perform }

            it { will_expect.to_not change(BitcoinDeposit, :count) }

            context 'with no confirmations' do
              subject(:second_perform) do
                service.perform(transaction.merge('confirmations' => 0))
              end

              it { will_expect.to_not change { deposit_address.reload.total } }
              it { will_expect.to_not change { user.reload.balance } }

              it do
                will_expect.to_not change { user.reload.unconfirmed_balance }
              end

              it do
                will_expect.to_not change { user.reload.unconfirmed_balance }
              end
            end

            context 'with 1 confirmation' do
              subject(:second_perform) do
                service.perform(transaction.merge('confirmations' => 1))
              end

              it { will_expect.to_not change { user.reload.balance } }
              it { will_expect.to_not change { deposit_address.reload.total } }

              it do
                will_expect.to change {
                  deposit.reload.confirmations
                }.from(0).to(1)
              end

              it do
                will_expect.to change { user.reload.unconfirmed_balance }.to(0)
              end
            end
          end
        end

        context 'when transaction has 1 confirmation' do
          let(:deposit) do
            BitcoinDeposit.where(txid: txid, index: 0).first
          end

          subject(:perform) do
            service.perform(transaction.merge('confirmations' => 1))
          end

          it { will_expect.to change { deposit_address.reload.total } }
          it { will_expect.to change { user.reload.balance } }

          it do
            will_expect.to_not change { user.reload.unconfirmed_balance }
          end

          context 'when transaction comes again' do
            before { perform }

            subject(:second_perform) { perform }

            it { will_expect.to_not change(BitcoinDeposit, :count) }

            context 'with 3 confirmation' do
              subject(:second_perform) do
                service.perform(transaction.merge('confirmations' => 3))
              end

              it { will_expect.to_not change { user.reload.balance } }

              it do
                will_expect.to change {
                  deposit.reload.confirmations
                }.from(1).to(3)
              end

              it do
                will_expect.to_not change { deposit_address.reload.total }
              end

              it do
                will_expect.to_not change { user.reload.unconfirmed_balance }
              end
            end
          end
        end
      end
    end
  end
end
