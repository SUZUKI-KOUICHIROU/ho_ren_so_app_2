require 'rails_helper'

RSpec.describe "Projectモデルのテスト", type: :model do
  let(:project) { FactoryBot.create(:project) }

  describe "各項目が有効な場合" do
    it "Projectが保存されるか" do
      expect(project).to be_valid
    end
  end

  describe "バリデーションのテスト" do
    context "leader_id(リーダーid)" do
      it "リーダ-のみ登録できる（leader_idがなければ登録できない）" do
        expect(build(:project, leader_id: nil)).to be_invalid
      end
    end
    context "name(プロジェクト名)" do
      it "空白の場合登録できない" do
        expect(build(:project, name: nil)).to be_invalid
      end
      it "21文字以上の場合登録できない" do
        expect(build(:project, name: 'あ' * 21)).to be_invalid
      end
    end
    context "description(概要)" do
      it "空白の場合登録できない" do
        expect(build(:project, description: nil)).to be_invalid
      end
      it "201文字以上の場合登録できない" do
        expect(build(:project, description: 'あ' * 201)).to be_invalid
      end
    end
    context "report_frequency(報告回数・報告日)" do
      it "report_frequencyがなければ登録できない" do
        expect(build(:project, report_frequency: nil)).to be_invalid
      end
      it "report_frequencyが1未満は登録できない" do
        expect(build(:project, report_frequency: 0)).to be_invalid
      end
      it "report_frequencyが1以上は登録できる" do
        expect(build(:project, report_frequency: 1)).to be_valid
      end
      it "report_frequencyが31以下は登録できる" do
        expect(build(:project, report_frequency: 31)).to be_valid
      end
      it "report_frequencyが32以上は登録できない" do
        expect(build(:project, report_frequency: 32)).to be_invalid
      end
    end
    context "next_report_date(次回報告日)" do
      it "next_report_dateがなければ登録できない" do
        expect(build(:project, next_report_date: nil)).to be_invalid
      end
    end
  end

  describe "reported_flag" do
    it "trueは登録できる" do
      project.reported_flag = true
      expect(project).to be_valid
    end
    it "falseは登録できる" do
      project.reported_flag = false
      expect(project).to be_valid
    end
    it "nilは登録できない" do
      project.reported_flag = nil
      expect(project).to be_invalid
    end
  end
end
