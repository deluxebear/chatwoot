# Local i18n customizations for our fork (zero upstream-file changes).
# Named zz_ so it runs after config/initializers/languages.rb, which resets
# available_locales and would otherwise wipe our additions.

# 1. Load translation overrides after all upstream locales: for the same key,
#    the file loaded last wins, so entries in customizations/i18n/backend/*.yml
#    override the community translations. (NOTE: the directory must NOT be
#    named `custom/` — that's a reserved ChatwootApp extension root.)
Rails.application.config.i18n.load_path += Dir[Rails.root.join('customizations/i18n/backend/*.yml')]

# 2. The administrate gem ships its own zh-CN translations (hyphen locale,
#    not part of the app language list). Allow it so the super admin panel
#    can render in Chinese.
SUPER_ADMIN_LOCALE = :'zh-CN'
Rails.application.config.i18n.available_locales += [SUPER_ADMIN_LOCALE]

# 3. Force the super admin panel (administrate) to use Chinese. The main app
#    keeps its own per-user/per-account locale switching (SwitchLocale).
Rails.application.config.to_prepare do
  SuperAdmin::ApplicationController.class_eval do
    around_action :switch_to_custom_super_admin_locale

    def switch_to_custom_super_admin_locale(&)
      I18n.with_locale(SUPER_ADMIN_LOCALE, &)
    end
  end
end
