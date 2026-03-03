# miniCMS

[![Ruby](https://img.shields.io/badge/Ruby-3.4+-CC342D.svg?style=flat&logo=ruby)](https://www.ruby-lang.org)
[![Rails](https://img.shields.io/badge/Rails-8.1+-E95241.svg?style=flat&logo=ruby-on-rails)](https://rubyonrails.org)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

A modern, lightweight Content Management System (CMS) and blogging platform built with Ruby on Rails 8.1. miniCMS provides a clean, intuitive interface for creating, managing, and sharing content with ease.

![miniCMS Banner](app/assets/images/banner.png)

## ✨ Features

### Content Management
- 📝 **Rich Text Editor** - Create beautiful posts with Action Text (Trix editor)
- 🏷️ **SEO-Friendly URLs** - Automatic slug generation with FriendlyId
- 📸 **Image Uploads** - Active Storage integration for avatars and attachments
- 🔍 **Full-Text Search** - Search across posts, users, and comments

### Social Features
- 💬 **Comments & Replies** - Nested comment system with threading
- ⭐ **Favorites** - Bookmark and organize favorite posts
- 👍 **Reactions** - Express feelings with emoji reactions
- 👥 **Follow System** - Follow users and get notified of their new posts
- 🔔 **Real-time Notifications** - Stay updated with activity notifications

### User Management
- 🔐 **Authentication** - Secure sign up/sign in with Devise
- 🎭 **User Roles** - Admin, Moderator, and Member roles
- 👤 **User Profiles** - Customizable profiles with avatars and bios
- 🌐 **Multilingual** - English and Arabic support (i18n)

### Admin Panel
- 📊 **Dashboard** - Overview of posts, users, and comments
- 🛠️ **Content Moderation** - Manage posts, comments, and users
- 📈 **Statistics** - Track platform growth and engagement

## 🚀 Tech Stack

| Component | Technology |
|-----------|------------|
| **Backend** | Ruby 3.4+, Rails 8.1 |
| **Database** | SQLite3 (development), PostgreSQL/MySQL (production ready) |
| **Frontend** | Hotwire (Turbo + Stimulus), Bootstrap 5 |
| **Authentication** | Devise |
| **Rich Text** | Action Text (Trix) |
| **File Uploads** | Active Storage |
| **Deployment** | Docker, Kamal |

## 📋 Requirements

- Ruby 3.4 or higher
- Rails 8.1 or higher
- SQLite3 (or PostgreSQL/MySQL for production)
- Node.js (for asset compilation)
- Yarn or npm
- ImageMagick (for image processing)

## 🛠️ Installation

### 1. Clone the Repository

```bash
git clone https://github.com/siddigsalahaldin/miniCMS.git
cd miniCMS
```

### 2. Install Dependencies

```bash
# Install Ruby gems
bundle install

# Install JavaScript dependencies
bin/importmap install
```

### 3. Database Setup

```bash
# Create and migrate the database
bin/rails db:create
bin/rails db:migrate

# (Optional) Load sample data
bin/rails db:seed
```

### 4. Start the Development Server

```bash
bin/rails server
```

Visit [http://localhost:3000](http://localhost:3000) in your browser.

## ⚙️ Configuration

### Environment Variables

Create a `.env` file in the root directory for environment-specific configuration:

```bash
# Optional: Configure application settings
RAILS_ENV=development
RAILS_MAX_THREADS=5
```

### Active Storage

For file uploads, configure Active Storage in `config/storage.yml`:

```yaml
local:
  service: Disk
  root: <%= Rails.root.join("storage") %>
```

### Email Configuration

Configure Action Mailer in `config/environments/development.rb`:

```ruby
config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }
```

## 📖 Usage

### Creating Posts

1. Sign in to your account
2. Click "New Post" in the navigation
3. Enter a title and write content using the rich text editor
4. Publish immediately or save as draft

### Managing Notifications

- Click the bell icon to view recent notifications
- Notifications are automatically marked as read when viewed
- Receive notifications for:
  - Comments on your posts
  - Replies to your comments
  - New followers
  - New posts from followed users

### Admin Dashboard

Admin users can access the dashboard at `/admin/dashboard`:

- View platform statistics
- Manage all posts, users, and comments
- Assign moderator/admin roles

## 🌍 Internationalization (i18n)

miniCMS supports multiple languages:

| Language | Code | Status |
|----------|------|--------|
| English | `en` | ✅ Complete |
| Arabic | `ar` | ✅ Complete |

### Switching Languages

Use the language switcher in the header to toggle between English and Arabic. The application automatically adjusts:
- Text direction (LTR/RTL)
- Date/time formatting
- Number formatting

### Adding New Languages

1. Create a new locale file in `config/locales/` (e.g., `fr.yml`)
2. Add translations following the existing structure
3. Update `config/application.rb` to include the new locale

```ruby
config.i18n.available_locales = [:en, :ar, :fr]
```

## 🧪 Testing

```bash
# Run the test suite
bin/rails test

# Run tests with coverage
bin/rails test:coverage

# Run system tests
bin/rails test:system
```

## 🚢 Deployment

### Docker Deployment

miniCMS is configured for Docker deployment:

```bash
# Build the Docker image
docker build -t minicms .

# Run the container
docker run -p 3000:3000 minicms
```

### Kamal Deployment

For production deployment with Kamal:

```bash
# Configure deployment in config/deploy.yml
kamal setup

# Deploy
kamal deploy
```

### Production Considerations

- Use PostgreSQL or MySQL for production database
- Configure a production-ready cache store (Redis)
- Set up a CDN for Active Storage assets
- Enable SSL/TLS for secure connections
- Configure environment variables for secrets

## 📁 Project Structure

```
miniCMS/
├── app/
│   ├── controllers/     # Request handlers
│   ├── models/          # Data models
│   ├── views/           # Templates
│   ├── helpers/         # View helpers
│   ├── assets/          # CSS, JS, images
│   └── javascript/      # Stimulus controllers
├── config/
│   ├── locales/         # i18n translations
│   ├── routes.rb        # URL routing
│   └── database.yml     # Database config
├── db/
│   ├── migrate/         # Database migrations
│   └── schema.rb        # Database schema
├── lib/                 # Custom libraries
├── public/              # Static files
├── test/                # Test files
└── Gemfile              # Ruby dependencies
```

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Code Style

This project uses RuboCop for Ruby linting:

```bash
bundle exec rubocop
```

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

```
MIT License

Copyright (c) 2026 Siddig Salahaldin

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

## 🙏 Acknowledgments

- [Ruby on Rails](https://rubyonrails.org/) - The web framework
- [Hotwire](https://hotwired.dev/) - Modern front-end development
- [Devise](https://github.com/heartcombo/devise) - Authentication solution
- [Bootstrap](https://getbootstrap.com/) - UI framework
- [Trix](https://trix-editor.org/) - Rich text editor

## 📞 Support

- **Issues**: Open an issue on [GitHub](https://github.com/siddigsalahaldin/miniCMS/issues)
- **Discussions**: Join the conversation on [GitHub Discussions](https://github.com/siddigsalahaldin/miniCMS/discussions)

---

Built with ❤️ using Ruby on Rails
