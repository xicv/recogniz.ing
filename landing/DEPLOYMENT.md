# Recogniz.ing Landing Page Deployment Guide

This guide covers how to deploy and maintain the Recogniz.ing landing page.

## Architecture Overview

```
xicv/recogniz.ing (Single Repository)
├── [Flutter App Source Code]
├── .github/workflows/
│   ├── release-all-platforms.yml  # Builds app, creates releases
│   ├── release.yml                 # Alternative release workflow
│   └── landing-deploy.yml         # Deploys landing to GitHub Pages
└── landing/                        # Landing page source
    ├── src/
    ├── public/
    │   └── downloads/              # App download artifacts (LFS)
    └── package.json
```

## Automated Deployment Flow

1. **Release Triggered**: Push a version tag (e.g., `v1.0.4`) to main branch
2. **Build & Release**: GitHub Actions builds all platforms and creates a GitHub Release
3. **Update Downloads**: Workflow commits download artifacts to `landing/public/downloads/`
4. **Deploy Landing**: The commit triggers `landing-deploy.yml` to build and deploy to GitHub Pages

## GitHub Pages Deployment

The landing page is automatically deployed to GitHub Pages using GitHub Actions. Deployment is triggered when:
- A release workflow commits updates to `landing/` folder
- Any push to `main` branch with changes to `landing/**` files
- Manual trigger via workflow_dispatch

## Managing Releases with Git LFS

The landing page stores downloadable files using Git LFS (Large File Storage).

### Current Setup

- ✅ Git LFS initialized
- ✅ `*.zip`, `*.tar.gz`, `*.apk`, `*.aab` files tracked by LFS
- ✅ LFS bandwidth: 10GB/month (free tier)

### Automated Release Process

When you push a version tag:

```bash
# Tag and push (triggers automated release)
git tag v1.0.4
git push origin v1.0.4
```

The GitHub Actions workflow will:
1. Build all platform binaries
2. Create GitHub Release with artifacts
3. Copy artifacts to `landing/public/downloads/[version]/`
4. Update `landing/public/downloads/manifest.json`
5. Commit and push changes (triggers landing deployment)

### Manual Release Process

If you need to add builds manually:

1. Copy build files to landing downloads:
   ```bash
   mkdir -p landing/public/downloads/1.0.4/macos
   cp path/to/recognizing-1.0.4-macos.zip landing/public/downloads/1.0.4/macos/
   ```

2. Update manifest.json:
   ```bash
   # Edit landing/public/downloads/manifest.json to include new version
   ```

3. Commit and push:
   ```bash
   git add landing/public/downloads/
   git commit -m "Add macOS v1.0.4 build"
   git push
   ```

## Custom Domain Configuration

### DNS Settings

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

### GitHub Pages Configuration

1. Go to: https://github.com/xicv/recogniz.ing/settings/pages
2. Set source to: **GitHub Actions**
3. Custom domain: `recogniz.ing`
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

## Development

### Landing Page Development
```bash
cd landing

# Install dependencies
npm install

# Start development server
npm run dev

# Build for production
npm run build
```

### Main App Development
See the main project README for Flutter app development.

## Troubleshooting

### GitHub Actions Issues
- Check the Actions tab for deployment status
- Ensure repository has GitHub Pages enabled
- Verify workflow permissions are correct (contents: read, pages: write, id-token: write)

### LFS Issues
```bash
# Reinstall Git LFS if needed
git lfs install
git lfs pull

# Check if file is tracked by LFS
git lfs track "*.zip"
```

### DNS Issues
- Use `dig recogniz.ing` to verify A records
- Check propagation time (24-48 hours)
- Ensure all 4 GitHub A records are set

## Resources

- [GitHub Pages Documentation](https://docs.github.com/en/pages)
- [Git LFS Documentation](https://git-lfs.com/)
- [Vite Deployment Guide](https://vitejs.dev/guide/static-deploy.html)
