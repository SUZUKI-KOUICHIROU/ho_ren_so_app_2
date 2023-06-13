require 'rails_helper'

RSpec.describe Question, type: :model do
  subject(:question) { FactoryBot.build(:question) }

  describe 'バリデーション' do
    context 'positionカラム' do
      it 'positionがなければ登録できない' do
        expect(build(:question, position: '')).to be_invalid
      end
    end

    context 'form_table_typeカラム' do
      it '質問形式がなければ登録できない' do
        expect(build(:question, form_table_type: '')).to be_invalid
      end
    end
  end

  # describe "using_flag" do
  #   it "trueは登録できる" do
  #     question.using_flag == true
  #     expect(question).to be_valid
  #   end
  #   it "falseは登録できる" do
  #     question.using_flag == false
  #     expect(question).to be_valid
  #   end
  #   it "nilは登録できない" do
  #     question.using_flag = nil
  #     expect(question).to be_invalid
  #   end
  # end

  # describe "required" do
  #   it "trueは登録できる" do
  #     question.required == true
  #     expect(question).to be_valid
  #   end
  #   it "falseは登録できる" do
  #     question.required == false
  #     expect(question).to be_valid
  #   end
  #   it "nilは登録できない" do
  #     question.required = nil
  #     expect(question).to be_invalid
  #   end
  # end
end
