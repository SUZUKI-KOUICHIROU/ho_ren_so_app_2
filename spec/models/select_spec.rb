require 'rails_helper'

RSpec.describe Select, type: :model do
  subject(:select) { FactoryBot.build(:select) }

  describe 'date_fieldの登録' do
    context 'label_nameカラム' do
      it 'label_nameがなければ登録できない' do
        expect(build(:select, label_name: '')).to be_invalid
      end
      it 'label_nameがあれば登録できる' do
        expect(build(:select, label_name: 'ラベル名')).to be_valid
      end
    end

    context 'field_typeカラム' do
      it 'field_typeがなければ登録できない' do
        expect(build(:select, field_type: '')).to be_invalid
      end
      it 'field_typeがあれば登録できる' do
        expect(build(:select, field_type: 'select')).to be_valid
      end
    end
  end
end
