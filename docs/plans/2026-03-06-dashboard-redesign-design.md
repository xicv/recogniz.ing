# Dashboard Redesign Design

**Date**: 2026-03-06
**Status**: Approved
**Goal**: Replace the over-engineered dashboard with a minimal, glanceable view that answers three questions: "How much have I used?", "How much quota remains?", and "What did I transcribe recently?"

## Context

The current dashboard has 6 stat sections across ~2,700 lines of code (including 1,446 lines of dead code in 5 never-imported widget files). Metrics are duplicated across widgets with conflicting calculations (two cost models differing by ~300x), unit bugs (minutes labeled as seconds), and fictional per-key stats (the `Transcription` model has no `apiKeyId` field).

UX research shows voice-typing users want a "10-second health check, not a data science project." The market leader (Wispr Flow, $81M raised) has no traditional dashboard at all.

## Architecture

### Layout: Three Sections

```
┌──────────────────────────────────────────────┐
│ Dashboard                                     │
├──────────┬──────────┬──────────┬─────────────┤
│ 📊 142   │ 📝 1.2k  │ ⏱️ 4.7h  │ 🔥 12 today │
│ Total    │ Words    │ Saved    │ Today       │
├──────────┴──────────┴──────────┴─────────────┤
│ API Quota  ████████████░░░░  847/1000 today   │
│ Key: My Primary Key          Resets in 14h    │
├──────────────────────────────────────────────┤
│ Recent Transcriptions                    All→ │
│ ┌─────────────────────────────────────┐      │
│ │ "Meeting notes from the standup..." │ 📋   │
│ │ 2 min ago · 234 words              │      │
│ ├─────────────────────────────────────┤      │
│ │ "Email draft to the design team..." │ 📋   │
│ │ 1 hour ago · 89 words              │      │
│ └─────────────────────────────────────┘      │
└──────────────────────────────────────────────┘
```

1. **Quick Stats Row** — 4 compact stat chips (total, words, time saved, today count)
2. **API Quota Bar** — horizontal progress bar with color coding and key name
3. **Recent Transcriptions** — last 5 transcriptions with copy button and "View All" link

### Data Flow

The dashboard reads only 2 providers (down from 4):

| Provider | Data | Used By |
|----------|------|---------|
| `transcriptionsProvider` | `List<Transcription>` | Quick Stats Row, Recent Transcriptions |
| `selectedKeyQuotaProvider` | `QuotaInfo?` | Quota Bar |

Stats are computed inline from the transcription list:
- **Total**: `transcriptions.length`
- **Words**: `transcriptions.fold(0, (sum, t) => sum + t.wordCount)`
- **Time Saved**: `totalWords / 40 * 60` seconds (40 WPM typing baseline), displayed as hours
- **Today**: `transcriptions.where((t) => isToday(t.createdAt)).length`

Providers no longer needed by the dashboard:
- `statisticsProvider` — redundant wrapper
- `enhancedStatisticsProvider` — over-engineered analytics
- `selectedKeyStatsProvider` — fictional per-key data

### Component Details

**QuickStatsRow** (~100 lines)
- 4 stat chips in a horizontal `Row` with `Expanded` children
- Each chip: icon, large value, small label
- Uses existing `SemanticColors` theme system
- No animations, no custom painters

**QuotaBar** (~80 lines)
- Visible only when `quotaInfo != null` (API key configured)
- Horizontal progress bar with percentage fill
- Color: green (<60%), amber (60-80%), red (>80%)
- Text: "X/1000 remaining today · Resets in Yh"
- Shows active key name from `selectedApiKeyProvider`

**Recent Transcriptions** (~50 lines, inline in dashboard_page.dart)
- First 5 from `transcriptionsProvider` (already sorted newest-first)
- Each item: text preview (max 2 lines), relative timestamp, word count, copy button
- "View All" link navigates to Transcriptions page
- Empty state: "No transcriptions yet. Press your hotkey to start."

## File Changes

### New Files
- `lib/features/dashboard/widgets/quick_stats_row.dart` (~100 lines)
- `lib/features/dashboard/widgets/quota_bar.dart` (~80 lines)

### Rewritten
- `lib/features/dashboard/dashboard_page.dart` — simplified to orchestrate 3 sections

### Deleted (9 files, ~2,700 lines)
- `widgets/compact_stats_card.dart` (244 lines) — replaced by quick_stats_row
- `widgets/quota_status_card.dart` (695 lines) — replaced by quota_bar
- `widgets/dashboard_metrics.dart` (171 lines) — removed
- `widgets/cost_analysis_widget.dart` (397 lines) — dead code
- `widgets/insights_widget.dart` (284 lines) — dead code
- `widgets/productivity_insights_widget.dart` (327 lines) — dead code
- `widgets/usage_pattern_widget.dart` (387 lines) — dead code
- `widgets/stat_card.dart` (51 lines) — dead code
- `widgets/transcription_tile.dart` (434 lines) — unused dashboard copy

### Not Changed
- Navigation structure (5 pages, Dashboard at index 1)
- `Transcription` model
- `QuotaInfo` class and computation
- Transcriptions page
- Any provider definitions outside dashboard scope

## Bugs Fixed by This Redesign

1. **Ring painter arc bug** — eliminated (no more custom painter)
2. **Unit mismatch** — avg duration in minutes labeled as seconds — eliminated
3. **Daily avg hardcoded to 7 days** — eliminated (no longer shown)
4. **Two conflicting cost models** — eliminated (no cost display)
5. **Fictional per-key stats** — eliminated (no per-key breakdown)
6. **"Days until exhaustion" misleading metric** — eliminated
7. **Redundant provider watches** — reduced from 4 to 2
