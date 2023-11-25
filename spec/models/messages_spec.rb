require 'rails_helper'

RSpec.describe Message, type: :model do
  subject(:message) { FactoryBot.build(:message) }

  describe 'messageの登録' do
    context 'titleカラム' do 
      
      it 'titleがなければ投稿できない' do
        expect(build(:message, title: '')).to be_invalid
      end           
      it '件名が30文字以出投稿できない' do
        expect(build(:message, title: 'a' * 31)).to be_invalid
      end
    end

    context 'message_detailカラム' do      
      it '報告日がなければ投稿できない' do
        expect(build(:message, message_detail: '')).to be_invalid
      end      
      it '500文字以下であること' do
        expect(build(:message, message_detail: 'a' * 501)).to be_invalid
      end
    end    
  end
end