require 'rails_helper'

RSpec.describe RadioButtonOptionString, type: :model do
  subject(:radio_button_option_string) { FactoryBot.build(:radio_button_option_string) }

  describe 'ラジオボタン選択肢の登録' do
    context 'option_string(選択肢)' do
      it 'option_string（選択肢）がなければ登録できない' do
        expect(build(:radio_button_option_string, option_string: '')).to be_invalid
      end
    end   
  end
end
