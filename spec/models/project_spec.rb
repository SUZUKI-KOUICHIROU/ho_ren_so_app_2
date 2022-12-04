require 'rails_helper'

RSpec.describe Project, type: :model do
  subject(:project) { FactoryBot.build(:project) }

  describe 'プロジェクト新規登録' do
    it '全てのカラムに値があれば登録出来る' do
      expect(project).to be_valid
    end

    context 'project_nameカラム' do
      it 'project_nameがなければ登録できない' do
        expect(build(:project, project_name: '')).not_to be_valid
      end

      it '20文字以下であること' do
        expect(build(:project, project_name: 'a' * 21)).not_to be_valid
      end
    end

    it 'leader_idがなければ登録できない' do
      expect(build(:project, leader_id: '')).not_to be_valid
    end

    it 'project_report_frequencyがなければ登録できない' do
      expect(build(:project, project_report_frequency: '')).not_to be_valid
    end

    it 'project_next_report_dateがなければ登録できない' do
      expect(build(:project, project_next_report_date: '')).not_to be_valid
    end

    context 'project_reported_flagカラム' do
      it 'trueとfalseは登録出来る' do
        expect(project).to allow_value(true).for(:project_reported_flag)
        expect(project).to allow_value(false).for(:project_reported_flag)
      end

      it 'nilは登録出来ない' do
        expect(project).not_to allow_value(nil).for(:project_reported_flag)
      end
    end
  end
end
