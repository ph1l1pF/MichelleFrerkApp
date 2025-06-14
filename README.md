# michelle_frerk

An App for the artist Michelle Frerk, which shows her artworks and allows to buy them.

It uses the Shopify Storefront API to fetch the products and the checkout process.

https://michellefrerk.com

## Increase version number

in pubspec.yaml, increase the 'version' to the next one, e.g. 1.0.0+2

(Execute the following commands for xcode to recognize the new version number)

```bash
flutter clean
flutter pub get
flutter build ios
```



## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

# Firebase Cloud Messaging

when an Authentication Key is created in apple developer page, it is important that the environment is Sandbox & Production otherwise, push notifications won't be delivered in prod mode (testflight or appstore distribution)

[Firebase Cloud Messaging](docs/authkey.png)
