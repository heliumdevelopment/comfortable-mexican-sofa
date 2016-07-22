class User < ActiveRecord::Base
  validates :first_name, presence: true
  validates :last_name, presence: true

  has_and_belongs_to_many :events
  has_many :notifications, as: :notificationable

  serialize :subscriptions, JSON

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  scope :manager, ->  { where(account_type: 'manager') }

  after_create :send_admin_mail

  include Gravtastic
  gravtastic

  TYPES = %w( manager owner ).freeze

  def owner?
    account_type == 'owner'
  end

  def manager?
    account_type == 'manager'
  end

  def full_name
    first_name + " " + last_name
  end

  def role
    account_type.gsub("_", " ").capitalize
  end

  def preferences
    if subscriptions
      subscriptions
    else
      Subscription.defaults
    end
  end

  # Checks through preferences and default subscriptions to
  # see if that person is subscribed to a act delivery
  def subscribed_to?(type, act, delivery)
    c = preferences[type.to_s]
    d = Subscription.defaults[type.to_s]

    if c && c[act.to_s] && c[act.to_s][delivery.to_s]
      # See if that user has that subscription
      c[act.to_s][delivery.to_s]
    elsif d && d[act.to_s] && d[act.to_s][delivery.to_s]
      # Check if there's a default for that setting
      d[act.to_s][delivery.to_s]
    else
      # Nothing found, just return false
      false
    end
  end

  # Resets user subscriptions to defaults
  def subscriptions_reset
    self.subscriptions = Subscription.defaults
  end

  def assigned_tasks
    Task.where(assignee_id: id)
  end

  private

  def send_admin_mail
    send_reset_password_instructions
  end
end
