# Helpifier v2

## Requirements

### To run Helpifier:

* OS X 10.7.3 or later
* HelpSpot 3.1.5 or later recommended

### To build from source:

* Xcode 4.3 or later
* Code signing certificate recommended

## Setup

When launching Helpifier v2 for the first time, go to Helpifier -> Preferences and enter your HelpSpot URL, username, and password.

Helpifier automatically checks for updates every 20 seconds. You can use the reload button in the lower left-hand corner to force an immediate update.

## Known issues

See [https://github.com/Figure53/Helpifier/issues](https://github.com/Figure53/Helpifier/issues)

## Code signing

If your builds are not code signed, Helpifier will still work. However, each new build will break access to your stored password,
and Keychain Services will prompt you to allow Helpifier to access your password each time you launch. Code signing helps with
keychain access by verifying that each new build of Helpifier is still Helpifier.

We will code sign our official builds with Figure 53's certificate. But since Helpifier is open-source, you will need to code sign
your own builds with your own certificate if you make changes to the code.

Helpifier.xcodeproj is set to use automatic profile selection, so as long as you have a code signing certificate installed, Xcode
will use it. If your certificate changes, your next build will prompt you to allow access to the keychain; clicking "Always Allow"
will add Helpifier's new identity to the access control list.