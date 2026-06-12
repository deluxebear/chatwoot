#!/usr/bin/env ruby
# Test Enterprise Mock Script

# Load Rails environment
require_relative 'config/environment'

puts '🔍 Testing Enterprise Feature Mocking...'
puts '=' * 50

# Check if we have any accounts
account_count = Account.count
puts "📊 Total accounts: #{account_count}"

if account_count == 0
  puts '❌ No accounts found. Creating a test account...'
  account = Account.create!(
    name: 'Test Enterprise Account',
    currency: 'USD',
    domain: 'test.chatwoot.dev',
    support_email: 'support@test.dev'
  )
  puts "✅ Created test account: #{account.name} (ID: #{account.id})"
else
  account = Account.first
  puts "✅ Using existing account: #{account.name} (ID: #{account.id})"
end

puts "\n🔧 Current Feature Status:"
puts '-' * 30

enterprise_features = %w[disable_branding audit_logs sla captain_integration custom_roles]

enterprise_features.each do |feature|
  status = account.feature_enabled?(feature) ? '✅ Enabled' : '❌ Disabled'
  puts "#{feature}: #{status}"
end

puts "\n📋 Current Plan Info:"
puts "Plan Name: #{account.custom_attributes['plan_name'] || 'Default'}"
puts "Subscribed Quantity: #{account.custom_attributes['subscribed_quantity'] || 'N/A'}"

puts "\n🚀 Enabling Enterprise Features..."
puts '-' * 40

# Update plan information
account.update!(
  custom_attributes: account.custom_attributes.merge(
    'plan_name' => 'Enterprise',
    'subscribed_quantity' => 100,
    'subscription_status' => 'active',
    'subscription_ends_on' => 1.year.from_now
  )
)

# Enable startup features
startup_features = %w[
  inbound_emails
  help_center
  campaigns
  team_management
  channel_twitter
  channel_facebook
  channel_email
  channel_instagram
]

puts 'Enabling startup features...'
account.enable_features(*startup_features)

puts 'Enabling enterprise features...'
account.enable_features(*enterprise_features)

account.save!

puts "\n✅ Feature Status After Enabling:"
puts '-' * 35

enterprise_features.each do |feature|
  status = account.feature_enabled?(feature) ? '✅ Enabled' : '❌ Disabled'
  puts "#{feature}: #{status}"
end

puts "\n📋 Updated Plan Info:"
puts "Plan Name: #{account.custom_attributes['plan_name']}"
puts "Subscribed Quantity: #{account.custom_attributes['subscribed_quantity']}"
puts "Subscription Status: #{account.custom_attributes['subscription_status']}"

puts "\n📊 All Enabled Features (#{account.enabled_features.count}):"
account.enabled_features.each { |feature, _| puts "  ✓ #{feature}" }

puts "\n🎉 Enterprise features successfully enabled!"
puts '=' * 50

puts "\n💡 Usage Examples:"
puts '- Access audit logs: Current.account.feature_enabled?(:audit_logs)'
puts '- Check SLA features: Current.account.feature_enabled?(:sla)'
puts '- Use custom roles: Current.account.feature_enabled?(:custom_roles)'