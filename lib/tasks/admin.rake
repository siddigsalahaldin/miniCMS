namespace :admin do
  desc "Create an admin user"
  task create: :environment do
    puts "Creating admin user..."
    
    email = ENV["EMAIL"] || "admin@minicms.com"
    username = ENV["USERNAME"] || "admin"
    password = ENV["PASSWORD"] || "password123"
    
    user = User.find_or_create_by!(email: email) do |u|
      u.username = username
      u.password = password
      u.password_confirmation = password
      u.role = "admin"
    end
    
    if user.persisted?
      puts "✓ Admin user created successfully!"
      puts "  Email: #{user.email}"
      puts "  Username: #{user.username}"
      puts "  Role: #{user.role}"
      puts ""
      puts "Sign in at: http://localhost:3000/users/sign_in"
      puts "Admin panel: http://localhost:3000/admin/dashboard"
    else
      puts "✗ Failed to create admin user:"
      user.errors.full_messages.each { |msg| puts "  - #{msg}" }
    end
  end
  
  desc "Make an existing user an admin"
  task promote: :environment do
    email = ENV["EMAIL"]
    
    if email.blank?
      puts "✗ Please provide EMAIL environment variable"
      puts "Usage: bin/rails admin:promote EMAIL=user@example.com"
      exit 1
    end
    
    user = User.find_by(email: email)
    
    if user.blank?
      puts "✗ User not found: #{email}"
      exit 1
    end
    
    user.update!(role: "admin")
    puts "✓ #{user.username} is now an administrator!"
  end
end
