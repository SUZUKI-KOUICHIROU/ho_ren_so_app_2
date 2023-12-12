require 'rails_helper'

RSpec.describe TextArea, type: :model do
  subject(:text_field) { FactoryBot.build(:text_field) }

  describe 'text_fieldの登録' do
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
        expect(build(:text_field, field_type: 'text_area')).to be_valid
      end
    end
  end
end
