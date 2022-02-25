class Join < ApplicationRecord
	validates_uniqueness_of :token
  validates_presence_of :token
  after_initialize :set_token

  private

  def set_token
    self.token = self.token.blank? ? generate_token : self.token
  end

  def generate_token
    tmp_token = SecureRandom.urlsafe_base64(6)
    self.class.where(:token => tmp_token).blank? ? tmp_token : generate_token
  end
end
