require 'rails_helper'

RSpec.describe Format, type: :model do
  subject(:format) { FactoryBot.build(:format) }

  describe 'fomatの登録' do
    context 'titleカラム' do
      it 'titleがなければ登録できない' do
        expect(build(:format, title: '')).to be_invalid
      end
    end
  end
end
