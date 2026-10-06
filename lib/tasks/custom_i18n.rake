# frozen_string_literal: true

# Maintenance tasks for our local i18n overlay (see AGENTS.md).
# Run `custom_i18n:verify` after every upstream sync.
# rubocop:disable Metrics/BlockLength
namespace :custom_i18n do
  desc 'Verify the overlay hooks survived an upstream merge'
  task verify: :environment do
    failures = []
    hooked_files = %w[
      app/javascript/dashboard/i18n/index.js
      app/javascript/widget/i18n/index.js
      app/views/super_admin/application/index.html.erb
      app/views/super_admin/application/_navigation.html.erb
      app/views/super_admin/application/_settings_menu.html.erb
      app/views/super_admin/app_configs/show.html.erb
      app/views/super_admin/devise/sessions/new.html.erb
    ]
    hooked_files.each do |path|
      failures << "missing CUSTOM-I18N-HOOK in #{path}" unless Rails.root.join(path).read.include?('CUSTOM-I18N-HOOK')
    end
    unless Rails.root.join('app/javascript/dashboard/i18n/custom/zh_CN.json').exist?
      failures << 'missing app/javascript/dashboard/i18n/custom/zh_CN.json'
    end
    failures << 'missing config/initializers/zz_custom_i18n.rb' unless Rails.root.join('config/initializers/zz_custom_i18n.rb').exist?
    failures << 'missing customizations/i18n/backend overrides' if Dir[Rails.root.join('customizations/i18n/backend/*.yml')].empty?

    if failures.empty?
      puts '✅ i18n overlay hooks intact.'
    else
      failures.each { |f| puts "❌ #{f}" }
      abort 'i18n overlay broken — re-apply the hooks (see AGENTS.md, CUSTOM-I18N-HOOK).'
    end
  end

  desc 'Report untranslated zh_CN keys (upstream + overlay combined)'
  task check: :environment do
    require 'json'

    en = flatten_locale_dir(Rails.root.join('app/javascript/dashboard/i18n/locale/en'))
    zh = flatten_locale_dir(Rails.root.join('app/javascript/dashboard/i18n/locale/zh_CN'))
    overlay = flatten_hash(JSON.parse(File.read(Rails.root.join('app/javascript/dashboard/i18n/custom/zh_CN.json'))))

    pending = en.select do |key, value|
      value.is_a?(String) &&
        value.gsub(/%\{[^}]*\}|\{\{[^}]*\}\}|\{[^}]*\}/, '') =~ /[a-zA-Z]{2,}/ &&
        (zh[key].nil? || zh[key] == value) && overlay[key].nil?
    end

    puts "Untranslated dashboard keys (excluding overlay): #{pending.size}"
    pending.first(20).each { |k, v| puts "  #{k} = #{v}" }
    puts '  ... (showing first 20)' if pending.size > 20
  end

  def flatten_locale_dir(dir)
    require 'json'
    Dir[File.join(dir, '*.json')].each_with_object({}) do |file, acc|
      acc.merge!(flatten_hash(JSON.parse(File.read(file))))
    end
  end

  def flatten_hash(hash, prefix = '')
    hash.each_with_object({}) do |(key, value), acc|
      path = prefix.empty? ? key.to_s : "#{prefix}.#{key}"
      value.is_a?(Hash) ? acc.merge!(flatten_hash(value, path)) : acc[path] = value
    end
  end
end
# rubocop:enable Metrics/BlockLength
