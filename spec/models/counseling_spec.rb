require 'rails_helper'

RSpec.describe Counseling, type: :model do
  subject(:message) { FactoryBot.build(:message) }

  describe 'counselingの登録' do # describeはテスト主題
    context '相談の送信' do # 条件
      before(:each) do
        # テスト用のプロジェクトを作成し、インスタンス変数に格納
        @project = create(:project) # これは本ファイルの他のテストでもプロジェクト作成を適用させるためのもの
      end
      it '送信相手、件名、相談内容があれば送信できる' do # it テスト内容の題名
        expect(build(:counseling, title: 'test', counseling_detail: 'test', send_to_all: true)).to be_valid # expect:期待値 to_be_valid:期待した結果になる(true)
      end
      it 'titleがなければ送信できない' do
        expect(build(:counseling, title: '')).to be_invalid # to_be_invalid falseになる
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

  describe '相談検索' do
    let(:search_params) { { keywords: 'example' } }
    it '検索が空で実行された場合、全相談を表示する' do
      expect(Counseling.search({})).to eq(Counseling.all)
    end
  end
end
