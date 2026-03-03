# Railway Deployment Configuration for miniCMS

## Overview

This guide covers deploying the miniCMS Rails application to Railway with production-ready configurations.

## Prerequisites

- Railway account (https://railway.app)
- Railway CLI installed: `npm install -g @railway/cli`
- GitHub account (for CI/CD integration)

## Quick Deploy

### Option 1: One-Click Deploy (Recommended)

[![Deploy on Railway](https://railway.app/button.svg)](https://railway.app/new)

1. Click the button above
2. Connect your GitHub repository
3. Railway will auto-detect the Rails app and configure everything

### Option 2: CLI Deploy

```bash
# Login to Railway
railway login

# Initialize project
railway init

# Add PostgreSQL database
railway add postgresql

# Set environment variables
railway variables set RAILS_MASTER_KEY=<your-master-key>
railway variables set SECRET_KEY_BASE=$(openssl rand -hex 64)
railway variables set RAILS_ENV=production

# Deploy
railway up
```

## Environment Variables

### Required

| Variable | Description | How to Generate |
|----------|-------------|-----------------|
| `RAILS_MASTER_KEY` | Decrypts credentials.yml.enc | From `config/master.key` |
| `SECRET_KEY_BASE` | Rails secret key | `rails secret` or `openssl rand -hex 64` |
| `RAILS_ENV` | Environment | Set to `production` |

### Optional (Production)

| Variable | Default | Description |
|----------|---------|-------------|
| `RAILS_LOG_LEVEL` | `info` | Log verbosity (`debug`, `info`, `warn`, `error`) |
| `RAILS_MAX_THREADS` | `5` | Rails max threads |
| `WEB_CONCURRENCY` | `2` | Puma workers |
| `AWS_ACCESS_KEY_ID` | - | S3 access key (if using S3) |
| `AWS_SECRET_ACCESS_KEY` | - | S3 secret (if using S3) |
| `AWS_REGION` | - | S3 region (if using S3) |
| `S3_BUCKET_NAME` | - | S3 bucket (if using S3) |

## Database Setup

Railway automatically provides `DATABASE_URL` when you add PostgreSQL:

```bash
# Add PostgreSQL
railway add postgresql

# Run migrations
railway run bin/rails db:migrate
```

### Database Configuration

The app is configured to use PostgreSQL in production:

```yaml
# config/database.yml
production:
  adapter: postgresql
  url: <%= ENV['DATABASE_URL'] %>
```

## Active Storage Configuration

### Local Storage (Development Only)

Files are stored locally but will be lost on redeploy in Railway.

### Cloud Storage (Production Recommended)

#### Amazon S3

1. Create an S3 bucket
2. Set environment variables:
```bash
railway variables set AWS_ACCESS_KEY_ID=<your-key>
railway variables set AWS_SECRET_ACCESS_KEY=<your-secret>
railway variables set AWS_REGION=us-east-1
railway variables set S3_BUCKET_NAME=your-bucket-name
```

3. Update `config/environments/production.rb`:
```ruby
config.active_storage.service = :amazon
```

#### DigitalOcean Spaces (Alternative)

```bash
railway variables set DO_SPACES_KEY=<your-key>
railway variables set DO_SPACES_SECRET=<your-secret>
railway variables set DO_SPACES_BUCKET=your-bucket
```

Update storage config:
```ruby
config.active_storage.service = :digitalocean
```

## CI/CD with GitHub Actions

### Setup

1. Add secrets to GitHub repository:
   - Go to Settings → Secrets and variables → Actions
   - Add `RAILWAY_TOKEN` (get from Railway CLI: `railway token`)
   - Add `RAILS_MASTER_KEY`
   - Add `SECRET_KEY_BASE`

2. The workflow will:
   - Run tests on every push
   - Run security scans (Brakeman)
   - Run linting (RuboCop)
   - Deploy to Railway on main branch push

### Manual Trigger

```bash
# Deploy manually
railway up
```

## Post-Deployment Tasks

### 1. Run Migrations

```bash
railway run bin/rails db:migrate
```

### 2. Create Admin User

```bash
railway run bin/rails runner "
  User.create!(
    email: 'admin@example.com',
    password: 'SecurePassword123!',
    password_confirmation: 'SecurePassword123!',
    admin: true
  )
"
```

### 3. Verify Deployment

```bash
# Check logs
railway logs

# Open app
railway open

# Health check
curl https://your-app.railway.app/up
```

## Troubleshooting

### Common Issues

#### 1. Database Connection Failed

```bash
# Verify DATABASE_URL is set
railway variables get DATABASE_URL

# Check PostgreSQL service is running
railway status
```

#### 2. Missing Master Key

```bash
# Option 1: Set as environment variable
railway variables set RAILS_MASTER_KEY=<your-key>

# Option 2: Upload the file
railway upload config/master.key
```

#### 3. Assets Not Compiling

```bash
# Check Node.js version in nixpacks.toml
# Ensure it matches your development version

# Rebuild without cache
railway up --detach --no-cache
```

#### 4. Memory Issues

Increase container memory in Railway dashboard:
- Go to project settings
- Increase memory limit (recommended: 512MB - 1GB for Rails)

#### 5. Slow Boot Times

Enable bootsnap caching:
```bash
# Already configured in Dockerfile
# Bootsnap precompiles on build
```

### View Logs

```bash
# Real-time logs
railway logs

# Last 100 lines
railway logs --lines 100

# Filter by service
railway logs --service web
```

### Access Rails Console

```bash
railway run bin/rails console
```

### Database Console

```bash
railway run bin/rails dbconsole
```

## Performance Optimization

### 1. Enable Caching

Already configured with Solid Cache:
```ruby
# config/environments/production.rb
config.cache_store = :solid_cache_store
```

### 2. Background Jobs

Solid Queue is configured for background processing:
```ruby
config.active_job.queue_adapter = :solid_queue
```

### 3. Database Connection Pool

```bash
railway variables set RAILS_MAX_THREADS=5
```

### 4. Asset CDN

For production, serve assets from CDN:
```ruby
# config/environments/production.rb
config.asset_host = "https://cdn.yourdomain.com"
```

## Security Checklist

- [ ] All secrets stored in Railway/ GitHub Secrets
- [ ] `config/master.key` never committed to git
- [ ] SSL/TLS enabled (Railway provides this automatically)
- [ ] Strong passwords for admin users
- [ ] Regular dependency updates (`bundle audit`)
- [ ] Brakeman security scans in CI
- [ ] Database backups enabled

## Monitoring

### Railway Dashboard

- View metrics: CPU, Memory, Network
- Check deployment history
- View logs in real-time

### Application Monitoring

Consider adding:
- **Sentry** for error tracking
- **Scout APM** for performance monitoring
- **New Relic** for full-stack monitoring

## Scaling

### Vertical Scaling

Increase resources in Railway dashboard:
- CPU: 0.5 → 1 → 2 cores
- Memory: 512MB → 1GB → 2GB

### Horizontal Scaling

Add more instances:
```bash
# Railway auto-scales based on traffic
# Configure in dashboard
```

### Database Scaling

Upgrade PostgreSQL plan in Railway dashboard for:
- More connections
- More storage
- Better performance

## Backup Strategy

### Database Backups

Railway provides automatic backups. Enable point-in-time recovery in dashboard.

### Manual Backup

```bash
# Export database
railway run bin/rails db:backup

# Or use pg_dump
railway run pg_dump $DATABASE_URL > backup.sql
```

### Restore

```bash
railway run psql $DATABASE_URL < backup.sql
```

## Support

- **Railway Docs**: https://docs.railway.app
- **Rails Docs**: https://guides.rubyonrails.org
- **Issues**: https://github.com/your-org/miniCMS/issues
