require 'rails_helper'

RSpec.describe ProjectUser, type: :model do
  describe '計算' do
    context '10 + 10の場合' do
      it '20になること' do
       expect(10 + 10).to eq 20
      end

      it '30にはならない' do
       expect(10 + 10).not_to eq 30
      end
    end
  end
end
