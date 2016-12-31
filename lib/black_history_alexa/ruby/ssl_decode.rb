require 'openssl'
require 'base64'

def decode(raw, signature)
  amazon_certificate, chain_certificates = parse_raw(raw)
  chain_certificates = [chain_certificates].flatten
  return false unless check_alt_name(amazon_certificate)
  return false unless check_not_expired(amazon_certificate)
  cert_store = OpenSSL::X509::Store.new
  cert_store.set_default_paths
  [amazon_certificate, chain_certificates].flatten.each { |c| cert_store.add_cert(c) }
  if cert_store.verify(amazon_certificate)
    chain_certificates.each do |c|
      return false unless cert_store.verify(c)
    end
    public_key = amazon_certificate.public_key
    signature_enc = Base64.decode64(signature)
    public_key.public_decrypt(signature_enc) # Asserted hash value
  else
    false
  end
end

def parse_raw(raw)
  raw.split(/(-----END CERTIFICATE-----)/)
     .select { |a| a != "\n" }
     .each_slice(2)
     .map(&:join)
     .map { |c| OpenSSL::X509::Certificate.new c }
end

def check_alt_name(certificate)
  certificate.extensions
             .find { |x| x.oid == 'subjectAltName' }
             .value
             .include? 'echo-api.amazon.com'
end

def check_not_expired(certificate)
  Time.now > certificate.not_before && Time.now < certificate.not_after
end
