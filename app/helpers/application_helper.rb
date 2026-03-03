module ApplicationHelper
  # Display time ago in words with proper locale handling
  # For Arabic (RTL), "منذ" comes before the time
  # For English (LTR), "ago" comes after the time
  def time_ago_in_words_locale(time)
    time_ago = time_ago_in_words(time)
    if I18n.locale == :ar || I18n.locale.to_s.start_with?('ar')
      "#{t('common.ago')} #{time_ago}"
    else
      "#{time_ago} #{t('common.ago')}"
    end
  end
end
