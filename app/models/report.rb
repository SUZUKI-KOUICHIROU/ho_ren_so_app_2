class Report < ApplicationRecord
  belongs_to :project
  belongs_to :user
  has_many :answers, dependent: :destroy
  has_many :report_confirmers, dependent: :destroy

  accepts_nested_attributes_for :answers, allow_destroy: true
  attribute :remanded, default: false
  attribute :resubmitted, default: false

  # validates :report_detail, presence: true
  validates :title, presence: true, length: { maximum: 30 }
  validates :report_day, presence: true
  validates :sender_name, presence: true

  scope :sarch, -> (search_params) do # scopeでsearcでメソッドを定義。(search_paramsは引数) 
    return if search_params.blank? # 検索フォームに値が無ければ以下の手順は行わない。
  
    title_cont(search_params[:title])
    .value_cont(search_params[:value])
    .updated_at_eq(search_params[:updated_at])
    .sender_name_cont(searc_params[:sender_name])
  end
  
  scope :title_cont, -> (title){where('title LIKE ?', "%#{title}%")} if title.present?
  scope :value_cont, -> (value){where('value LIKE ?', "%#{value}%")} if value.present?
  scope :updated_at_eq, -> (updated_at){where('updated_at', "%#{updated_at}%")} if updated_at.present?
  scope :sender_name_cont, -> (sender_name){where('sender_name LIKE ?', "%#{sender_name}%")} if sender_name.present?
  #scope :メソッド名 -> (引数) { SQL文 }
  #if 引数.present?をつけることで、検索フォームに値がない場合は実行されない
end
