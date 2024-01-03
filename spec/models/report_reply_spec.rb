require 'rails_helper'

RSpec.describe ReportReply, type: :model do
  describe "report_replyの登録" do
    context "reply_contentカラム" do
      it "返信本文があれば投稿できる" do
        expect(build(:report_reply, reply_content: 'a')).to be_valid
      end

      it "返信本文がなければ投稿できない" do
        expect(build(:report_reply, reply_content: '')).to be_invalid
      end

      it "返信本文が500文字までは投稿できる" do
        expect(build(:report_reply, reply_content: "a" * 500)).to be_valid
      end

      it "返信本文が500文字を超えると投稿できない" do
        expect(build(:report_reply, reply_content: "a" * 501)).to be_invalid
      end
    end
  end
end
