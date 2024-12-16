# Model to handle JWT revocation
class JwtDenylist < ApplicationRecord
  # Includes Devise's denylist revocation strategy
  include Devise::JWT::RevocationStrategies::Denylist

  # Specifies the database table for storing revoked JWTs
  self.table_name = 'jwt_denylists'
end