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

  scope :search, ->(search_params) do
    return all if search_params.blank?

    reports = all

    if search_params[:title].present?
      reports = reports.title_like(search_params[:title])
    end

    if search_params[:updated_at].present?
      reports = reports.updated_at(search_params[:updated_at])
    end

    if search_params[:sender_name].present?
      reports = reports.sender_name_like(search_params[:sender_name])
    end

    if search_params[:value].present?
      reports = reports.answer_value_like(search_params[:value])
    end

    reports
  end

  scope :title_like, ->(title) { where('title LIKE ?', "%#{title}%") }
  scope :updated_at, ->(updated_at) { where('updated_at BETWEEN ? AND ?', "#{updated_at} 00:00:00", "#{updated_at} 23:59:59") }
  scope :sender_name_like, ->(sender_name) { where('sender_name LIKE ?', "%#{sender_name}%") }
  scope :answer_value_like, ->(value) { joins(:answers).where('answers.value LIKE ?', "%#{value}%") }
  # scope :answer_value_like, -> (value) { joins(:answers).select('reports.*, answers.value').where('answers.value LIKE ?', "%#{value}%") }
end
