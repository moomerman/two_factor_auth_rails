module SessionsHelper
  def google_authenticator_qrcode(user)
    data = "otpauth://totp/two_factor_demo?secret=#{user.auth_secret}"
    data = Rack::Utils.escape(data)
    url = "https://chart.googleapis.com/chart?chs=200x200&chld=M|0&cht=qr&chl=#{data}"
    return image_tag(url, :alt => 'Google Authenticator QRCode')
  end
end
