require 'alexa_verifier'

def verify(cert_chain_url, signature, request)
  verifier = AlexaVerifier.build do |c|
    c.verify_signatures = true
    c.verify_timestamps = true
    c.timestamp_tolerance = 60 # seconds
  end
  verifier.verify!(cert_chain_url, signature, request.to_json)
end
