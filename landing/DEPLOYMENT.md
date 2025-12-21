# Recogniz.ing Landing Page Deployment Guide

This guide covers how to deploy and maintain the Recogniz.ing landing page.

## GitHub Pages Deployment

The landing page is automatically deployed to GitHub Pages using GitHub Actions. Any push to the `main` branch will trigger a new deployment.

## Managing Releases with Git LFS

The landing page stores downloadable files using Git LFS (Large File Storage) to keep the repository size manageable.

### Current Setup

- ✅ Git LFS initialized
- ✅ `*.zip` files tracked by LFS
- ✅ macOS build (52MB) stored in LFS
- ✅ LFS bandwidth: 10GB/month (free tier)

### Adding New Builds

#### Method 1: Using the Release Script (Recommended)

```bash
# Add all platforms
./scripts/release.sh all 1.0.3

# Add specific platform only
./scripts/release.sh macos 1.0.3
```

#### Method 2: Manual Process

1. Copy your build files to the appropriate directory:
   ```bash
   # Example for macOS
   cp path/to/your-build.zip public/downloads/macos/1.0.3/
   ```

2. Add files to Git (they'll be tracked by LFS automatically):
   ```bash
   git add public/downloads/macos/1.0.3/*.zip
   ```

3. Update the manifest.json:
   ```bash
   # Edit public/downloads/manifest.json to include new version
   ```

4. Commit and push:
   ```bash
   git commit -m "Add macOS v1.0.3 build"
   git push origin main
   ```

## Custom Domain Configuration

### DNS Settings for Spaceship.com

For the domain `recogniz.ing`, configure these DNS records:

#### Root Domain (@)
```
Type: A Record
Name: @
Value: 185.199.108.153
TTL: 3600

Type: A Record
Name: @
Value: 185.199.109.153
TTL: 3600

Type: A Record
Name: @
Value: 185.199.110.153
TTL: 3600

Type: A Record
Name: @
Value: 185.199.111.153
TTL: 3600
```

#### WWW Subdomain
```
Type: CNAME
Name: www
Value: xicv.github.io
TTL: 3600
```

### GitHub Pages Configuration

1. Go to: https://github.com/xicv/recogniz.ing/settings/pages
2. Set source to: **GitHub Actions**
3. Custom domain: `recogniz.inge` (will auto-detect after DNS setup)
4. Enable HTTPS when available

## Git LFS Management

### Check LFS Status
```bash
# Check which files are tracked by LFS
git lfs ls-files

# Check LFS storage usage
git lfs ls-files | wc -l
```

### File Size Limits
- Free tier: 10GB storage + 10GB bandwidth/month
- Maximum file size: 2GB
- Bandwidth counts ALL downloads/clones

### Monitoring Usage
GitHub LFS usage can be monitored in your GitHub account settings under "Billing > Git LFS".

## Build Process

### Development
```bash
# Install dependencies
pnpm install

# Start development server
pnpm dev

# Build for production
pnpm build
```

### Deployment
```bash
# Build and deploy (automatically via GitHub Actions)
pnpm build
git add .
git commit -m "Update site"
git push
```

## Troubleshooting

### LFS Issues
```bash
# Reinstall Git LFS if needed
git lfs install
git lfs pull

# Check if file is tracked by LFS
git check-attr public/downloads/macos/1.0.2/recognizing-1.0.2-macos.zip
```

### GitHub Actions Issues
- Check the Actions tab for deployment status
- Ensure repository has GitHub Pages enabled
- Verify workflow permissions are correct

### DNS Issues
- Use `dig recogniz.ing` to verify A records
- Check propagation time (24-48 hours)
- Ensure all 4 GitHub A records are set

## Repository Structure

```
landing/
├── public/
│   └── downloads/
│       ├── manifest.json          # Download manifest
│       ├── macos/
│       │   └── *.zip              # Stored in LFS
│       ├── windows/
│       ├── linux/
│       └── android/
├── .github/
│   └── workflows/
│       └── deploy.yml           # GitHub Actions workflow
├── .gitattributes               # LFS file tracking rules
├── scripts/
│   └── release.sh              # Release management script
└── vite.config.ts               # Vite configuration
```

## Resources

- [GitHub Pages Documentation](https://docs.github.com/en/pages)
- [Git LFS Documentation](https://git-lfs.com/)
- [Spaceship DNS Guide](https://www.spaceship.com/knowledgebase/)
- [Vite Deployment Guide](https://vitejs.dev/guide/static-deploy.html)