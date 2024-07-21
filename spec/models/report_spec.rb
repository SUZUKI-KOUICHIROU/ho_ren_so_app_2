require 'rails_helper'

RSpec.describe Report, type: :model do
  subject(:report) { FactoryBot.build(:report) }

  describe 'reportの登録' do
    context 'titleカラム' do
      it 'titleがなければ投稿できない' do
        expect(build(:report, title: '')).to be_invalid
      end

      it '30文字以下であること' do
        expect(build(:report, title: 'a' * 31)).to be_invalid
      end
    end

    context 'report_dayカラム' do
      it '報告日がなければ投稿できない' do
        expect(build(:report, report_day: '')).to be_invalid
      end
    end

    context 'sender_nameカラム' do
      it '報告者がなければ投稿できない' do
        expect(build(:report, sender_name: '')).to be_invalid
      end
    end

    context 'report_read_flagカラム' do
      it '報告作成時、報告確認状況(report_read_flag)が未読(false)になる' do
        report = FactoryBot.build(:report)
        expect(report.report_read_flag).to eq(false)
      end
    end
  end

  describe '報告検索' do
    let(:search_params) { { created_at: '2024-07-01', keywords: 'example' } }
    it '検索が空で実行された場合、全報告を表示する' do
      expect(Report.search({})).to eq(Report.all)
    end

    it '検索した日付があれば、その日付の報告を表示する' do
      expect(Report).to receive(:created_at).with(search_params[:created_at]).and_call_original
      Report.search(search_params)
    end

    it '検索したキーワードを含む報告があれば、その報告を表示する' do
      expect(Report).to receive(:keywords_like).with(search_params[:keywords]).and_call_original
      Report.search(search_params)
    end
  end
end
