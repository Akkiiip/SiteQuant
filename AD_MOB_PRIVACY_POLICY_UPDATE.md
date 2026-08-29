# SiteQuant: Required Privacy Policy Updates for AdMob

Update the public SiteQuant Privacy Policy at:

https://sites.google.com/view/sitequantprivacypolicy/home

before releasing an Android build with production AdMob identifiers.

## Advertising and consent

- SiteQuant displays Google AdMob banner advertisements on Android when ads are enabled and the user is eligible to receive ads.
- The Google User Messaging Platform (UMP) SDK requests updated consent information when the app launches and presents a consent form when Google requires one.
- Where the consent configuration requires it, SiteQuant provides a **Privacy Choices** entry in Settings so users can revisit their choices.
- SiteQuant does not load an AdMob banner until the UMP SDK indicates that ads may be requested.

## Information processed for advertising

Describe the information that Google Mobile Ads may process to deliver, measure, secure, and improve ads, as applicable to the AdMob configuration selected by the publisher. This can include:

- advertising identifiers, including the Android Advertising ID where available;
- device and technical information, such as device type, operating system, language, IP address, and app information;
- approximate location derived from IP address;
- ad interactions, including ad views, clicks, and ad performance/diagnostic information.

State whether ads are personalized or non-personalized according to the publisher's final AdMob and UMP configuration. Do not claim that SiteQuant itself creates advertising profiles or collects this information independently of the Google advertising SDK.

## Crash reporting

- SiteQuant uses Firebase Crashlytics to collect crash and diagnostic information needed to identify and fix application stability issues.
- Describe the categories of diagnostic/device information processed by Crashlytics according to the deployed Firebase configuration and Google documentation.

## Third-party processing

- Identify Google LLC and its relevant affiliates/service providers as third parties that process information for Google Mobile Ads, UMP consent management, and Firebase Crashlytics.
- Link to Google's privacy information and explain that Google processes data under its own privacy terms where applicable.

## Choices, retention, and contact

- Explain how users can access the in-app **Privacy Policy** and, when shown, **Privacy Choices** settings.
- Describe any other available choices, including Android advertising controls, where applicable.
- State the policy effective/update date and describe how material updates will be communicated.
- Provide a current developer contact method for privacy questions or requests.

## Play Console alignment

Before publishing, align the Google Play Data Safety declaration and AdMob account privacy/messaging settings with the final production implementation. Only disclose data categories and purposes that apply to the enabled SDKs, ad formats, ad personalization setting, mediation partners, and Firebase configuration.
