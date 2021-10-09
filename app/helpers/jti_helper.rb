module JtiHelper
  def self.build_jti(iat)
    jti_raw = [ENV["JWT_TOKEN"], iat].join(':').to_s
    Digest::MD5.hexdigest(jti_raw)
  end
end
