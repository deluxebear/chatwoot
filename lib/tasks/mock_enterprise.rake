namespace :mock do
  desc "Mock enterprise features for development/testing"
  namespace :enterprise do
    desc "Enable enterprise features for an account"
    task :enable, [:account_id] => :environment do |_task, args|
      account_id = args[:account_id]
      account = account_id ? Account.find(account_id) : Account.first
      
      if account.nil?
        puts "❌ No account found. Please create an account first."
        next
      end

      enterprise_features = %w[
        disable_branding
        audit_logs
        sla
        captain_integration
        custom_roles
      ]

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
      puts "✅ Enabling startup plan features..."
      account.enable_features(*startup_features)
      
      puts "✅ Enabling enterprise features..."
      account.enable_features(*enterprise_features)
      
      account.save!
      
      puts "🎉 Enterprise features enabled successfully!"
      puts
      puts "Enabled features:"
      account.enabled_features.each { |feature, _| puts "  ✓ #{feature}" }
    end

    desc "Disable enterprise features for an account"
    task :disable, [:account_id] => :environment do |_task, args|
      account_id = args[:account_id]
      account = account_id ? Account.find(account_id) : Account.first
      
      if account.nil?
        puts "❌ No account found."
        next
      end

      enterprise_features = %w[
        disable_branding
        audit_logs
        sla
        captain_integration
        custom_roles
      ]

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
      account.disable_features(*enterprise_features)
      account.disable_features(*startup_features)
      
      account.save!
      
      puts "✅ Enterprise features disabled. Reverted to default plan."
    end

    desc "Show enterprise feature status for an account"
    task :status, [:account_id] => :environment do |_task, args|
      account_id = args[:account_id]
      account = account_id ? Account.find(account_id) : Account.first
      
      if account.nil?
        puts "❌ No account found."
        next
      end

      enterprise_features = %w[
        disable_branding
        audit_logs
        sla
        captain_integration
        custom_roles
      ]

      puts "📊 Feature Status for Account: #{account.name} (ID: #{account.id})"
      puts "Plan: #{account.custom_attributes['plan_name'] || 'Default'}"
      puts "Subscribed Quantity: #{account.custom_attributes['subscribed_quantity'] || 'N/A'}"
      puts "Subscription Status: #{account.custom_attributes['subscription_status'] || 'N/A'}"
      puts
      puts "Enterprise Features:"
      enterprise_features.each do |feature|
        status = account.feature_enabled?(feature) ? "✅ Enabled" : "❌ Disabled"
        puts "  #{feature}: #{status}"
      end
      puts
      puts "All Enabled Features (#{account.enabled_features.count}):"
      account.enabled_features.each { |feature, _| puts "  ✓ #{feature}" }
    end

    desc "Enable all premium features for all accounts (use with caution)"
    task :enable_all => :environment do
      puts "🚨 WARNING: This will enable enterprise features for ALL accounts!"
      print "Are you sure? (y/N): "
      
      response = STDIN.gets.chomp.downcase
      unless response == 'y' || response == 'yes'
        puts "❌ Cancelled."
        next
      end

      enterprise_features = %w[
        disable_branding
        audit_logs
        sla
        captain_integration
        custom_roles
      ]

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

      Account.find_each do |account|
        puts "🚀 Enabling enterprise features for account: #{account.name} (ID: #{account.id})"
        
        account.update!(
          custom_attributes: account.custom_attributes.merge(
            'plan_name' => 'Enterprise',
            'subscribed_quantity' => 100,
            'subscription_status' => 'active',
            'subscription_ends_on' => 1.year.from_now
          )
        )

        account.enable_features(*(startup_features + enterprise_features))
        account.save!
      end
      
      puts "🎉 Enterprise features enabled for all accounts!"
    end
  end
end