# michelle_frerk

An App for the artist Michelle Frerk, which shows her artworks and allows to buy them.

https://michellefrerk.com

The app uses...

- Shopify Storefront API to fetch the products and for the checkout process.
- Firebase Cloud Messaging to send push notifications to the users.
- Fire store to store user data for the 'Gewinnspiel' feature.

## Architecture

The code consists of...

- models containing data and domain logic (not much present in this small app)
- repositories for caching and state handling
- services for the communication with external APIs
- views/widgets for the UI


## Increase version number

in pubspec.yaml, increase the 'version' to the next one, e.g. 1.0.0+2

(Execute the following commands for xcode to recognize the new version number)

```bash
flutter clean
flutter pub get
flutter build ios
```

# Firebase Cloud Messaging

when an Authentication Key is created in apple developer page, it is important that the environment is Sandbox & Production otherwise, push notifications won't be delivered in production build (testflight or appstore distribution)

[Firebase Cloud Messaging](docs/authkey.png)
