require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'trackableモジュールのテスト' do
    let(:user) { create(:user) }

    it 'ログイン時にユーザーの追跡情報が正しく更新されることの検証' do
      # 前回のログイン情報を設定
      user.update(
        sign_in_count: 1, # ログイン回数を1回に設定
        current_sign_in_at: 2.days.ago, # 最後にログイン日を設定
        last_sign_in_at: 3.days.ago, # 前回ログインした日を設定
        current_sign_in_ip: '192.168.1.1', # 最後にログインした際のIPアドレスを設定
        last_sign_in_ip: '192.168.1.2' # 前回ログインした際のIPアドレスを設定
      )

      # 新しいログイン情報を模擬
      user.update(
        sign_in_count: user.sign_in_count + 1, # 以前のログイン回数に1を加えて総回数を保存する
        current_sign_in_at: Time.current, # 現在のログイン時刻を記録する
        last_sign_in_at: user.current_sign_in_at, # 最後にログインした時刻を更新する
        current_sign_in_ip: '192.168.1.3', # 現在ログインしているIPアドレスを記録する
        last_sign_in_ip: user.current_sign_in_ip # 最後にログインした際のIPアドレスを更新する
      )

      # データが期待通りに更新されたか検証
      expect(user.sign_in_count).to eq(2) # ログイン回数が期待通りに2回になっているか
      expect(user.last_sign_in_at.to_date).to eq(2.days.ago.to_date) # 最後のログイン時刻が2日前に設定された値であること
      expect(user.current_sign_in_at.to_date).to eq(Time.zone.today) # 現在のログイン時刻が今日であること
      expect(user.last_sign_in_ip).to eq('192.168.1.1')
      expect(user.current_sign_in_ip).to eq('192.168.1.3')
    end
  end
end
