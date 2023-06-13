require 'rails_helper'

RSpec.describe TextArea, type: :model do
  subject(:text_field) { FactoryBot.build(:text_field) }

  describe 'text_fieldの登録' do
    context 'label_nameカラム' do
      it 'label_nameがなければ登録できない' do
        expect(build(:text_field, label_name: '')).to be_invalid
      end
    end

    context 'field_typeカラム' do
      it 'field_typeがなければ登録できない' do
        expect(build(:text_field, field_type: '')).to be_invalid
      end
    end
  end
end
