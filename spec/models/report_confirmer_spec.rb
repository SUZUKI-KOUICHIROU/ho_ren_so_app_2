require 'rails_helper'

RSpec.describe ReportConfirmer, type: :model do
  subject(:report_confirmer) { FactoryBot.build(:report_confirmer) }

  describe '報告の確認' do
    context 'report_confirmer_idカラム' do
      it '報告確認者のidがなければ登録できない' do
        expect(build(:report_confirmer, report_confirmer_id: '')).to be_invalid
      end
    end

    context 'report_confirmation_flagカラム' do
      it 'trueとfalseは登録出来る' do
        expect(report_confirmer).to allow_value(true).for(:report_confirmation_flag)
        expect(report_confirmer).to allow_value(false).for(:report_confirmation_flag)
      end
    end
  end
end
