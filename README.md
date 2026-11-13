# Verified Gestalt — experimental source build

This is a GPL-3.0-or-later fork of GoldenNugget-Team/worstgestalt at aaf7c7e209484227278966bd0eb2ee1d244cb9a0. It retains the upstream worse_query bridge and KAMUI engine, with original license files and notices.

## What changed
- Focused UI reads real ProductType and DeviceSupportsGenerativeModelSystems from disk. No reset-to-off toggle.
- Capability-only mode sets the known generative-model flag to a Boolean true.
- Optional identity mode additionally sets ProductType to iPhone16,1. It deliberately does not spoof CPU, board, hardware model or region.
- Fresh lease read-back checks the entire plist after each operation.
- First-change original is saved separately, every write also makes an upstream backup, and restore verifies its result.
- Failed writes attempt immediate rollback. Export VerifiedOriginal.plist and retain a full device backup before rebooting.

## Findings from upstream source
PresetsView.aiStaged is @State initialized to false. Closing/recreating the screen resets it without reading the file. Off does not prove failed persistence. Upstream saveOperation already performs structural read-back verification, so its saved message was stronger evidence than our earlier diagnosis claimed.
AIRegionPreset.productTypeKey uses the ThinningProductType key for detection; its write uses the actual ProductType key. Its full-spoof HWModelStr comment does not match the supplied key map. Its AI preset does not set DeviceSupportsGenerativeModelSystems. These are concrete code observations, not proof of an AI activation fix.

## Build an unsigned IPA
No iOS SDK, Swift compiler or connected iPhone was available in this session. This source has NOT been compiled or device tested. No working AI activation is claimed.

Upload this complete folder (including .github) to your own GitHub repository, then run Actions -> Build unsigned IPA. Download the VerifiedGestalt-unsigned artifact. The workflow uses a macOS runner and XcodeGen; its first run is the actual compile check. Alternatively on a Mac with Xcode and XcodeGen:

    xcodegen generate
    xcodebuild -project VerifiedGestalt.xcodeproj -scheme VerifiedGestalt -configuration Release -sdk iphoneos -derivedDataPath build CODE_SIGNING_ALLOWED=NO build

The workflow packages the app into an unsigned IPA. Sign with a sideloader that provisions a working App Group. Keep com.apple.security.application-groups in the signed entitlements. Do not send Apple credentials to anyone. You can change the bundle/App Group IDs to your own before signing.

## Use
Restore previous tools' changes first. Open app and Read again. Export the original backup after your first apply; the file is created before the mutation. Try capability-only first. Read again after closing/reopening; record the actual values. Identity mode is optional and can break device services. This tool verifies plist values only. It cannot verify Apple server eligibility, completeness of downloaded assets, runtime memory requirements, or model execution. A 6.49 GB storage entry does not resolve these questions. If Siri stalls again, restore the original and reboot rather than layering more spoof tools.

## Validation performed
Source inspection and package consistency checks only. Apple framework compile, signing and on-device behavior remain untested.
