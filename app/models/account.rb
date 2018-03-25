# frozen_string_literal: true

# Top level model responsible for registration, authentication, settings, ...
# Is never exposed to anyone but the account owner
class Account < ApplicationRecord
  acts_as_target

  # Associations
  has_one :user, class_name: 'Profiles::User', dependent: :destroy

  # Devise
  devise :database_authenticatable, :registerable, :rememberable

  # Attributes
  accepts_nested_attributes_for :user
  # Do not allow email change
  attr_readonly :email

  # Delegations
  delegate :handle, to: :user, prefix: true

  # Validations
  validates :user, presence: true, on: :create
  devise :validatable
end
