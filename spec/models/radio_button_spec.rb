require 'rails_helper'

RSpec.describe RadioButton, type: :model do
  subject(:radio_button) { FactoryBot.build(:radio_button) }

  describe 'date_fieldの登録' do
    context 'label_nameカラム' do
      it 'label_nameがなければ登録できない' do
        expect(build(:radio_button, label_name: '')).to be_invalid
      end
    end

    context 'field_typeカラム' do
      it 'field_typeがなければ登録できない' do
        expect(build(:radio_button, field_type: '')).to be_invalid
      end
    end
  end
end
