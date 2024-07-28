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
end
