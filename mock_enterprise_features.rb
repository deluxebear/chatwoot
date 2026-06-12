#!/usr/bin/env ruby
# Mock Enterprise Features Script
# This script enables enterprise features for testing purposes

require_relative 'config/environment'

class MockEnterpriseFeatures
  ENTERPRISE_FEATURES = %w[
    disable_branding
    audit_logs
    sla
    captain_integration
    custom_roles
  ].freeze

  STARTUP_FEATURES = %w[
    inbound_emails
    help_center
    campaigns
    team_management
    channel_twitter
    channel_facebook
    channel_email
    channel_instagram
  ].freeze

  def self.enable_for_account(account_id = nil)
    account = account_id ? Account.find(account_id) : Account.first

    if account.nil?
      puts '❌ No account found. Please create an account first.'
      return false
    end

    puts "🚀 Enabling enterprise features for account: #{account.name} (ID: #{account.id})"

    # Update account plan information
    account.update!(
      custom_attributes: account.custom_attributes.merge(
        'plan_name' => 'Enterprise',
        'subscribed_quantity' => 100,
        'subscription_status' => 'active',
        'subscription_ends_on' => 1.year.from_now
      )
    )

    # Enable all enterprise features
    puts '✅ Enabling startup plan features...'
    account.enable_features(*STARTUP_FEATURES)

    puts '✅ Enabling enterprise features...'
    account.enable_features(*ENTERPRISE_FEATURES)

    account.save!

    puts '🎉 Enterprise features enabled successfully!'
    puts
    puts 'Enabled features:'
    account.enabled_features.each { |feature, _| puts "  ✓ #{feature}" }

    true
  end

  def self.disable_for_account(account_id = nil)
    account = account_id ? Account.find(account_id) : Account.first

    if account.nil?
      puts '❌ No account found.'
      return false
    end

    puts "⬇️  Disabling enterprise features for account: #{account.name} (ID: #{account.id})"

    # Reset to default plan
    account.update!(
      custom_attributes: account.custom_attributes.merge(
        'plan_name' => 'Hacker',
        'subscribed_quantity' => 2,
        'subscription_status' => 'active'
      )
    )

    # Disable enterprise features
    account.disable_features(*ENTERPRISE_FEATURES)
    account.disable_features(*STARTUP_FEATURES)

    account.save!

    puts '✅ Enterprise features disabled. Reverted to default plan.'

    true
  end

  def self.show_status(account_id = nil)
    account = account_id ? Account.find(account_id) : Account.first

    if account.nil?
      puts '❌ No account found.'
      return
    end

    puts "📊 Feature Status for Account: #{account.name} (ID: #{account.id})"
    puts "Plan: #{account.custom_attributes['plan_name'] || 'Default'}"
    puts
    puts 'Enterprise Features:'
    ENTERPRISE_FEATURES.each do |feature|
      status = account.feature_enabled?(feature) ? '✅ Enabled' : '❌ Disabled'
      puts "  #{feature}: #{status}"
    end
    puts
    puts 'All Enabled Features:'
    account.enabled_features.each { |feature, _| puts "  ✓ #{feature}" }
  end

  def self.run
    case ARGV[0]
    when 'enable'
      account_id = ARGV[1]&.to_i
      enable_for_account(account_id)
    when 'disable'
      account_id = ARGV[1]&.to_i
      disable_for_account(account_id)
    when 'status'
      account_id = ARGV[1]&.to_i
      show_status(account_id)
    else
      puts 'Usage:'
      puts '  ruby mock_enterprise_features.rb enable [account_id]'
      puts '  ruby mock_enterprise_features.rb disable [account_id]'
      puts '  ruby mock_enterprise_features.rb status [account_id]'
      puts
      puts 'If no account_id is provided, uses the first account.'
    end
  end
end

# Run the script if called directly
MockEnterpriseFeatures.run if __FILE__ == $0