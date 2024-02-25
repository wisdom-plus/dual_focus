module UuidGenerator
  extend ActiveSupport::Concern

  included do
    before_create :generate_uuid
  end

  def generate_uuid
    self.uuid = SecureRandom.uuid if uuid.blank?
  end
end
