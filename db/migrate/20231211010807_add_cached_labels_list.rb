class AddCachedLabelsList < ActiveRecord::Migration[7.0]
  def change
    add_column :conversations, :cached_label_list, :string
    Conversation.reset_column_information
    # acts-as-taggable-on >= 10 activates Taggable::Caching automatically once the cached column exists
    ActsAsTaggableOn::Taggable::Cache.included(Conversation) if defined?(ActsAsTaggableOn::Taggable::Cache)
  end
end
