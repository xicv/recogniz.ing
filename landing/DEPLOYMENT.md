# Recogniz.ing Landing Page Deployment Guide

This guide covers how to deploy and maintain the Recogniz.ing landing page.

## Architecture Overview

```
xicv/recogniz.ing (Single Repository)
├── [Flutter App Source Code]
├── .github/workflows/
│   ├── release-all-platforms.yml  # Builds app, creates GitHub Releases
│   ├── build-windows.yml          # Windows-specific build
│   └── landing-deploy.yml         # Deploys landing to GitHub Pages
└── landing/                        # Landing page source
    ├── src/
    ├── public/
    │   └── downloads/
    │       └── manifest.json       # Version manifest (only tracked file)
    └── package.json
```

## Automated Deployment Flow

1. **Release Triggered**: Push a version tag (e.g., `v1.0.8`) to main branch
2. **Build & Release**: GitHub Actions builds all platforms and creates a GitHub Release
3. **Update Manifest**: Workflow updates `landing/public/downloads/manifest.json` with version info
4. **Deploy Landing**: The commit triggers `landing-deploy.yml` to build and deploy to GitHub Pages

> **Note**: Build artifacts (.zip, .apk, .aab) are stored in **GitHub Releases**, not in the repository. The `downloads/` folder is gitignored except for `manifest.json`.

## GitHub Pages Deployment

The landing page is automatically deployed to GitHub Pages using GitHub Actions. Deployment is triggered when:
- A release workflow commits updates to `manifest.json`
- Any push to `main` branch with changes to `landing/**` files
- Manual trigger via workflow_dispatch

## Managing Releases

### Automated Release Process

When you push a version tag:

```bash
# Tag and push (triggers automated release)
git tag v1.0.8
git push origin v1.0.8
```

The GitHub Actions workflow will:
1. Build all platform binaries
2. Create GitHub Release with artifacts attached
3. Update `landing/public/downloads/manifest.json` with version info
4. Commit and push manifest changes (triggers landing deployment)

### Download URLs

Users download from GitHub Releases:
```
https://github.com/xicv/recogniz.ing/releases/download/v{VERSION}/recognizing-{VERSION}-{platform}.zip
```

The landing page `DownloadsView.vue` reads these URLs from the manifest and constructs download links.

### Manual Release Process

If you need to create a release manually:

1. Build the app using `make build-macos` (or other platform)
2. Create a GitHub Release via web UI or `gh` CLI:
   ```bash
   gh release create v1.0.8 \
     --title "Recogniz.ing v1.0.8" \
     --notes "Release notes here..."
   ```
3. Upload build artifacts:
   ```bash
   gh release upload v1.0.8 build/macos/recognizing-1.0.8-macos.zip
   ```
4. Update `landing/public/downloads/manifest.json` manually

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
- Verify workflow permissions are correct (contents: write, pages: write)

### DNS Issues
- Use `dig recogniz.ing` to verify A records
- Check propagation time (24-48 hours)
- Ensure all 4 GitHub A records are set

## Resources

- [GitHub Pages Documentation](https://docs.github.com/en/pages)
- [GitHub Releases Documentation](https://docs.github.com/en/repositories/releasing-projects-on-github)
- [Vite Deployment Guide](https://vitejs.dev/guide/static-deploy.html)
