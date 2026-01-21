// Version information - auto-synced from package.json during version bump
// DO NOT EDIT MANUALLY - updated by scripts/version_manager.dart
export const VERSION = '1.15.1'

// Get current version as string
export function getVersion(): string {
  return VERSION
}

// Get version with 'v' prefix for GitHub tags
export function getVersionWithPrefix(): string {
  return `v${VERSION}`
}

// Get download URL for a platform
export function getDownloadUrl(platform: string, ext: string = 'zip'): string {
  return `https://github.com/xicv/recogniz.ing/releases/download/${getVersionWithPrefix()}/recognizing-${VERSION}-${platform}.${ext}`
}
