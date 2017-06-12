require "bumbleberry/bumbleberry"
#require "bumbleberry"

module BumbleberryCacheHelper
  def cache_retrieve(key)
    return _profile("cache_retrieve #{key}") do
      Rails.cache.fetch(cache_key(key))
    end
  end

  def cache(key, data)
    Rails.cache.fetch(cache_key(key), expires_in: 30.days) do
      data
    end
  end

private

  def cache_key(key)
    "bumbleberry-#{request.user_agent}-#{key}"
  end
end
