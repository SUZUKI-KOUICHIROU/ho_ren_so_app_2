require 'rails_helper'

RSpec.describe CheckBox, type: :model do
  subject(:check_box) { FactoryBot.build(:check_box) }

  describe 'date_fieldの登録' do
    context 'label_nameカラム' do
      it 'label_nameがなければ登録できない' do
        expect(build(:check_box, label_name: '')).to be_invalid
      end
      it 'label_nameがあれば登録できる' do
        expect(build(:check_box, label_name: 'ラベル名')).to be_valid
      end
    end

    context 'field_typeカラム' do
      it 'field_typeがなければ登録できない' do
        expect(build(:check_box, field_type: '')).to be_invalid
      end
      it 'field_typeがあれば登録できる' do
        expect(build(:check_box, field_type: 'check_box')).to be_valid
      end
    end
  end
end
