# frozen_string_literal: true

# Mock enterprise plan state for local development/testing.
#
# Feature lists are derived from upstream sources of truth so they stay
# current across upstream syncs without manual maintenance:
#   - config/features.yml entries marked `premium: true`
#   - plan tier constants in Enterprise::Billing::ReconcilePlanFeaturesService
#
# rubocop:disable Metrics/BlockLength
namespace :mock do
  namespace :enterprise do
    desc 'Enable all premium features for an account (default: first account)'
    task :enable, [:account_id] => :environment do |_task, args|
      account = mock_enterprise_account(args[:account_id])
      next if account.nil?

      puts "🚀 Enabling enterprise features for account: #{account.name} (ID: #{account.id})"
      mock_enterprise_enable(account)
      mock_enterprise_set_installation_plan('enterprise')
      puts "🎉 Enterprise features enabled! (#{mock_enterprise_premium_features.size} premium features)"
      mock_enterprise_print_status(account)
    end

    desc 'Disable premium features for an account (default: first account)'
    task :disable, [:account_id] => :environment do |_task, args|
      account = mock_enterprise_account(args[:account_id])
      next if account.nil?

      puts "⬇️  Disabling enterprise features for account: #{account.name} (ID: #{account.id})"
      mock_enterprise_disable(account)
      puts '✅ Reverted account to the default plan.'
      puts 'ℹ️  Installation plan is left as-is; run `bundle exec rails chatwoot:dev:toggle_variant` to switch the installation back to community.'
    end

    desc 'Show enterprise feature status for an account (default: first account)'
    task :status, [:account_id] => :environment do |_task, args|
      account = mock_enterprise_account(args[:account_id])
      next if account.nil?

      mock_enterprise_print_status(account)
    end

    desc 'Enable premium features for ALL accounts (use with caution)'
    task enable_all: :environment do
      puts '🚨 WARNING: This will enable enterprise features for ALL accounts!'
      print 'Are you sure? (y/N): '
      next puts('❌ Cancelled.') unless %w[y yes].include?($stdin.gets.chomp.downcase)

      Account.find_each do |account|
        puts "🚀 Enabling enterprise features for account: #{account.name} (ID: #{account.id})"
        mock_enterprise_enable(account)
      end
      mock_enterprise_set_installation_plan('enterprise')
      puts '🎉 Enterprise features enabled for all accounts!'
    end

    private

    def mock_enterprise_premium_features
      from_features_yml = Featurable::FEATURE_LIST.select { |feature| feature['premium'] }.pluck('name')
      from_plan_tiers = Enterprise::Billing::ReconcilePlanFeaturesService::PREMIUM_PLAN_FEATURES
      (from_features_yml + from_plan_tiers).uniq
    end

    def mock_enterprise_account(account_id)
      account = account_id ? Account.find(account_id) : Account.first
      puts '❌ No account found. Please create an account first (e.g. `bundle exec rails db:seed`).' if account.nil?
      account
    end

    def mock_enterprise_enable(account)
      account.update!(
        custom_attributes: account.custom_attributes.merge(
          'plan_name' => 'Enterprise',
          'subscribed_quantity' => 100,
          'subscription_status' => 'active',
          'subscription_ends_on' => 1.year.from_now
        ),
        limits: { 'captain_responses' => 100_000, 'captain_documents' => 100_000 }
      )
      account.enable_features!(*mock_enterprise_premium_features)
    end

    def mock_enterprise_disable(account)
      account.update!(
        custom_attributes: account.custom_attributes.merge(
          'plan_name' => 'Hacker',
          'subscribed_quantity' => 2,
          'subscription_status' => 'active'
        ),
        limits: {}
      )
      account.disable_features!(*mock_enterprise_premium_features)
    end

    def mock_enterprise_set_installation_plan(plan)
      config = InstallationConfig.find_or_initialize_by(name: 'INSTALLATION_PRICING_PLAN')
      config.value = plan
      config.save!
      GlobalConfig.clear_cache
      puts "💾 INSTALLATION_PRICING_PLAN → #{plan} (keeps the reconcile job from disabling premium features)"
    end

    def mock_enterprise_print_status(account)
      puts "📊 Feature status for account: #{account.name} (ID: #{account.id})"
      puts "Installation plan: #{InstallationConfig.find_by(name: 'INSTALLATION_PRICING_PLAN')&.value || 'community'}"
      puts "Account plan: #{account.custom_attributes['plan_name'] || 'Default'}"
      puts "Subscribed quantity: #{account.custom_attributes['subscribed_quantity'] || 'N/A'}"
      puts "Captain limits: #{account.captain_monthly_limit.to_h}"
      puts
      puts "Premium features (#{mock_enterprise_premium_features.size}):"
      mock_enterprise_premium_features.sort.each do |feature|
        puts "  #{feature}: #{account.feature_enabled?(feature) ? '✅ enabled' : '❌ disabled'}"
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
