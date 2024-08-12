class TelegramAuthenticationService
  def self.authenticate_user(init_data)
    parsed_data = CGI.parse(init_data)

    return false unless valid_telegram_data?(parsed_data)

    user_data = JSON.parse(parsed_data['user'].first)
    user_data['id']
  end

  private_class_method def self.valid_telegram_data?(parsed_data)
    telegram_token = Rails.application.credentials.dig(:telegram, :bot)
    received_hash = parsed_data.delete('hash')&.first

    return false unless received_hash

    data_check_string = parsed_data.keys.sort.map do |key|
      "#{key}=#{parsed_data[key].first}"
    end.join("\n")

    secret_key = OpenSSL::HMAC.digest(
      'SHA256',
      'WebAppData',
      telegram_token
    )

    check_hash = OpenSSL::HMAC.hexdigest(
      'SHA256',
      secret_key,
      data_check_string
    )

    check_hash == received_hash
  end
end
