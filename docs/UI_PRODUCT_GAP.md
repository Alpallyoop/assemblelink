# UI Product Gap

> **Status (2026-10-20): addressed in 0.1.0.** The raw install-queue and winget-ID plumbing now sits behind toolkit cards and a guided setup wizard (plan, approve, install, results, receipts); the advanced view keeps the details. This note is kept for history.

## Current issue

The UI exposes too much plumbing:

- Build install queue
- winget ID
- raw command
- receipt/state concepts

## Intended UX

The user should see:

Content Creation
Ready

Recommended tools:
- OBS Studio
- GIMP
- Audacity
- Blender

Button:
Install Recommended Tools

After click:

Installing tools...

OBS Studio: blocked, files in use
GIMP: already current
Audacity: already current
Blender: already current

Total time: 13.62s

## Required change

Replace Generate install plan and Build install queue with one primary action:

Install Recommended Tools

Internally it should generate queue, execute queue, poll progress, render result, and link receipt.
