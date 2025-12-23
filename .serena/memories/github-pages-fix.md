GitHub Pages Deployment Issues and Fixes:

1. MIME Type Error for JS modules:
   - GitHub Pages sometimes serves JS files with incorrect MIME type
   - Solution: Add .nojekyll file to root directory
   - Already exists in dist/.nojekyll

2. 404 for app_icon.svg:
   - The icon exists at /assets/icons/app_icon.svg in dist
   - GitHub Pages might need time to propagate
   - The path in index.html is correct: "/assets/icons/app_icon.svg"

3. Workflow fix (Dec 2025):
   - Updated landing-deploy.yml to use single deploy job (matches Vite docs)
   - Fixed npm cache path from 'landing/**/package-lock.json' to 'landing/package-lock.json'
   - Used setup-node's built-in npm cache instead of separate cache step

4. Main solution:
   - Add proper MIME type configuration via .nojekyll
   - Ensure GitHub Pages has proper time to deploy
   - Check if GitHub Pages is using the correct branch (gh-pages or main)