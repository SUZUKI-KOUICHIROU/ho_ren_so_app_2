require 'rails_helper'

RSpec.describe CheckBoxOptionString, type: :model do
  subject(:check_box_option_string) { FactoryBot.build(:check_box_option_string) }

  describe 'チェックボックス選択肢の登録' do
    context 'option_string(選択肢)' do
      it 'option_string（選択肢）がなければ登録できない' do
        expect(build(:check_box_option_string, option_string: '')).to be_invalid
      end
    end
  end
end
