json.extract! member, :id, :first_name, :last_name, :address_1, :address_2, :city, :state, :zip, :phone_1, :phone_1_type, :phone_2, :phone_2_type, :email_1, :email_2, :emergency_name, :emergency_relation, :emergency_phone, :playing_status, :created_at, :updated_at
json.url member_url(member, format: :json)
