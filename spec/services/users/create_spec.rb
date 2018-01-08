RSpec.describe Services::Users::Create do
  subject(:service) { Services::Users::Create }

  describe '.perform' do
    let(:attributes) { {} }

    subject(:perform) { service.perform(attributes) }

    context 'with valid attributes' do
      let(:attributes) do
        {
          username: 'test',
          password: 'passs'
        }
      end

      it 'creates a user' do
        expect {
          perform
        }.to change(User, :count).by(1)
      end
    end
  end
end
