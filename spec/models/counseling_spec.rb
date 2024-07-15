require 'rails_helper'

RSpec.describe Counseling, type: :model do
  subject(:message) { FactoryBot.build(:message) }

  describe 'counselingの登録' do
    context '相談の送信' do
      before(:each) do
        # テスト用のプロジェクトを作成し、インスタンス変数に格納
        @project = create(:project)
      end
      it '送信相手、件名、相談内容があれば送信できる' do
        expect(build(:counseling, title: 'test', counseling_detail: 'test', send_to_all: true)).to be_valid
      end
      it 'titleがなければ送信できない' do
        expect(build(:counseling, title: '')).to be_invalid
      end
      it '件名が31文字以上は送信できない' do
        expect(build(:counseling, title: 'a' * 31)).to be_invalid
      end
      it '相談内容がなければ送信できない' do
        expect(build(:counseling, counseling_detail: '')).to be_invalid
      end
      it '501文字以上は投稿できない' do
        expect(build(:counseling, counseling_detail: 'a' * 501)).to be_invalid
      end
    end

    context '送信相手' do
      it '送信相手が空の場合は送信できない' do
        expect(build(:counseling, send_to_all: 'false' && :counseling, send_to: '')).to be_invalid
      end
    end
  end
end
