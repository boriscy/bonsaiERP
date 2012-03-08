#encoding: utf-8
module Models::Loan::Base
  extend ActiveSupport::Concern

  included do
    with_options :if => :is_in_edit? do |opt|
      # Common callbacks
      opt.before_create :set_create_data
      opt.before_save :set_common_save_data

      # Accessible attributes
      attr_accessible :ref_number, :contact_id, :total, :project_id, :account_id, :date

      # validations
      opt.validates_presence_of :ref_number, :contact, :contact_id, :account_id, :total, :account_id, :date
      opt.validates_presence_of :project, :if => "project_id.present?"
      opt.validates :contact_id, :contact => {:clases => ["Client", "Supplier"]}
      opt.validate  :account_is_money
    end
  end

  private
  
  private
  
  def set_create_data
    self.creator_id = UserSession.user_id
    self.state = "draft"
    self.balance = 0
  end

  def set_common_save_data
    self.balance = total
    self.modified_by = UserSession.user_id
    self.currency_id = account.currency_id
  end

  def account_is_money
    unless account.is_money?
      self.errors[:account_id] << I18n.t("errors.messages.loan.ilegal_account")
    end
  end
end
