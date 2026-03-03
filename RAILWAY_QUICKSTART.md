# 🚀 Railway Quick Start

Deploy miniCMS to Railway in 5 minutes!

## Prerequisites

- [ ] Railway account (free at https://railway.app)
- [ ] Railway CLI installed: `npm install -g @railway/cli`
- [ ] GitHub account (optional, for CI/CD)

## Step-by-Step Deployment

### 1️⃣ Login to Railway

```bash
railway login
```

### 2️⃣ Initialize Project

```bash
railway init
```

Select your GitHub repository or create a new project.

### 3️⃣ Add PostgreSQL Database

```bash
railway add postgresql
```

This automatically sets the `DATABASE_URL` environment variable.

### 4️⃣ Set Environment Variables

```bash
# Set master key (from config/master.key)
railway variables set RAILS_MASTER_KEY=$(cat config/master.key)

# Generate and set secret key base
railway variables set SECRET_KEY_BASE=$(openssl rand -hex 64)

# Set production environment
railway variables set RAILS_ENV=production
```

### 5️⃣ Deploy

```bash
railway up
```

Wait for the build to complete (~2-3 minutes).

### 6️⃣ Run Migrations

```bash
railway run bin/rails db:migrate
```

### 7️⃣ Create Admin User

```bash
railway run bin/rails runner "User.create!(email: 'admin@example.com', password: 'password123', password_confirmation: 'password123', admin: true)"
```

### 8️⃣ Open Your App

```bash
railway open
```

Visit `https://your-app.railway.app` and sign in with the admin account!

## 🎉 Done!

Your miniCMS is now live on Railway!

---

## Next Steps

### Enable CI/CD (Optional)

1. Go to your Railway project dashboard
2. Click "Settings" → "GitHub"
3. Connect your repository
4. Push to `main` branch to auto-deploy

### Configure Custom Domain (Optional)

1. Go to Railway project → Settings
2. Click "Domains"
3. Add your custom domain
4. Update DNS records as instructed

### Set Up Cloud Storage (Recommended for Production)

For persistent file uploads:

```bash
# Amazon S3
railway variables set ACTIVE_STORAGE_SERVICE=amazon
railway variables set AWS_ACCESS_KEY_ID=your-key
railway variables set AWS_SECRET_ACCESS_KEY=your-secret
railway variables set AWS_REGION=us-east-1
railway variables set S3_BUCKET_NAME=your-bucket
```

## 🆘 Troubleshooting

### Build Failed

Check logs:
```bash
railway logs
```

Common issues:
- Missing `RAILS_MASTER_KEY` - ensure it's set correctly
- Database connection error - verify PostgreSQL is added
- Asset compilation error - check Node.js version in `nixpacks.toml`

### App Won't Start

```bash
# View real-time logs
railway logs --follow

# Check environment variables
railway variables list

# Restart deployment
railway restart
```

### Database Errors

```bash
# Run migrations again
railway run bin/rails db:migrate

# Check database URL
railway variables get DATABASE_URL
```

## 📚 More Documentation

- [Full Railway Guide](RAILWAY_DEPLOYMENT.md)
- [Environment Variables](.env.example)
- [Main README](README.md)

## 📞 Support

- Railway Docs: https://docs.railway.app
- Rails Docs: https://guides.rubyonrails.org
