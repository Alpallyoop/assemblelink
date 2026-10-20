# Changelog

All notable AssembleLink changes are documented here.

## 0.1.0 - Release candidate

### Added

- Windows desktop dashboard for workstation setup, updates, software inventory, drivers, toolkits, and reconstruction blueprints.
- Curated catalog with 72 reviewed entries, 21 job toolkits, 34 categories, and nine job families.
- Local software/version intelligence with managed, application-candidate, developer-component, driver-component, and system-component classification.
- Approval-bound Winget planning and execution with durable progress, interruption recovery, verification, and receipts.
- Native workstation assurance that verifies sealed system, driver, software, and catalog evidence.
- Clean-machine release matrix auditing and fail-closed Authenticode gates.
- Desktop/laptop setup profiles with a bounded maximum planned storage allocation, dependency-aware footprint estimates, and visible headroom.
- Version availability: inventory, catalog and updates views show installed version, available version and an update/current/unknown state per item; unknown is never reported as current.
- Install history page listing AssembleLink's own execution records and uninstall receipts with integrity status (SHA-256 sidecar checked, bounded read, copies skipped). Winget does not keep downloaded installers, and the UI says so.
- Toolkit cards: a "See the tools" overlay listing each toolkit's tools, and a recycle button that builds an update plan from the cached scan.
- Goodbye overlay shown while the app removes itself after Uninstall AssembleLink (waving panda, spinning head, repeating until the window closes; respects reduced motion).
- `scripts/release/build_candidate_v1.ps1` builds, hashes, audits and stages an unsigned development candidate; `scripts/audit/al_ui_security_audit_v1.ps1` audits the UI source and Tauri configuration.

### Security

- Packaged scripts, catalogs, and manifests are restored from trusted application resources at startup.
- Fixture evidence is rejected by live workstation assurance.
- Unknown provider/update state is never represented as current.
- Browser preview cannot execute workstation commands.
- Vite/PostCSS development dependencies are pinned to advisory-cleared versions.
- Machine type, storage ceiling, and per-item estimates are bound into the approved plan digest; oversized and tampered plans fail closed.
- Engine calls are time-limited (software scan 420 s, other engines 240 s) with the whole process tree stopped on timeout; installs are exempt. A stalled Winget scan can no longer block the app.
- Self-uninstall rejects uninstaller paths containing cmd metacharacters or control characters.
- UI source is audited for eval, inline handlers, external network use and a strict content security policy.

### Release blockers

- Production publication requires a trusted Authenticode certificate and timestamp. No signing route is in place: the SignPath Foundation application was declined for insufficient public track record, and Azure individual validation was set aside because it would publish the maintainer's name and locality. Only unsigned `UNSIGNED-DEVELOPMENT` previews are published until an organization identity or a later SignPath approval exists.
- Eleven controlled clean-machine scenarios remain pending.
