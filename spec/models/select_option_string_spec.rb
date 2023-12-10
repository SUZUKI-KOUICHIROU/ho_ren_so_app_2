require 'rails_helper'

RSpec.describe SelectOptionString, type: :model do
  subject(:select_option_string) { FactoryBot.build(:select_option_string) }

  describe 'プルダウン選択肢の登録' do
    context 'option_string(選択肢)' do
      it 'option_string（選択肢）がなければ登録できない' do
        expect(build(:select_option_string, option_string: '')).to be_invalid
      end
      it 'option_string（選択肢）があれば登録できる' do
        expect(build(:select_option_string, option_string: 'test')).to be_valid
      end
    end
  end
end
