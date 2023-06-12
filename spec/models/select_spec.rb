require 'rails_helper'

RSpec.describe Select, type: :model do
  subject(:select) { FactoryBot.build(:select) }

  describe 'date_fieldの登録' do
    context 'label_nameカラム' do
      it 'label_nameがなければ登録できない' do
        expect(build(:select, label_name: '')).to be_invalid
      end
    end

    context 'field_typeカラム' do
      it 'field_typeがなければ登録できない' do
        expect(build(:select, field_type: '')).to be_invalid
      end
    end
  end
end
