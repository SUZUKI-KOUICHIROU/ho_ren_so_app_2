require 'rails_helper'

RSpec.describe DateField, type: :model do
  subject(:date_field) { FactoryBot.build(:date_field) }

  describe 'date_fieldの登録' do
    context 'label_nameカラム' do
      it 'label_nameがなければ登録できない' do
        expect(build(:text_field, label_name: '')).to be_invalid
      end
      it 'label_nameがあれば登録できる' do
        expect(build(:text_field, label_name: 'ラベル名')).to be_valid
      end
    end

    context 'field_typeカラム' do
      it 'field_typeがなければ登録できない' do
        expect(build(:text_field, field_type: '')).to be_invalid
      end
      it 'field_typeがあれば登録できる' do
        expect(build(:text_field, field_type: 'date_field')).to be_valid
      end
    end
  end
end
