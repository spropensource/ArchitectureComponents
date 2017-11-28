# Architecture Components

A port of Android Architecture Components to iOS. 


## Motivation 

When building an app for both iOS and Android, there are advantages to defining 
a single app architecture and applying it on both platforms. Primarily, it 
saves time by solving the data modeling and component interactions once for 
both platforms. Additionally, maintenance is somewhat eased because changes 
will be similar on both platforms. 

Apple's developer guides and the UIKit framework provide little concrete
guidance for architecting an app to be reliable and maintainable. This has lead 
the iOS developer community to create [many iOS app architectures][MVX] and 
have [lively debates][MCHADO] about their usefulness. 

[Android Architecture Components][AAC] provide Android developers with a
general-purpose, clean, repeatable pattern for creating data-driven,
reactive-style apps. The components provide a clean separation of concerns and
abstract away many of the intricacies that arise when handling data updates
properly for every phase of the UI lifecycle. Finally, Google provides
[concrete recommendations][GUIDE] for common real-world app development
problems. 

Since iOS lacks a first-party application architecture and Android now has 
a very nice first-party application architecture, it seems reasonable to adopt 
Android's architecture on both platforms in instances when app delivery would 
benefit from sharing an app architecture. 


## Roadmap

Next steps:

- Enable Carthage and CocoaPods installation
- Improve automated test coverage
- Provide full documentation comments
- Improve README with getting started information
- Create an example app
- Setup continuous integration
- Add logging
- Implement Room Persistence Library
- Implement Paging Library
- Support tvOS, watchOS, macOS

Completed:

- Implement Lifecycle components
- Implement LiveData components


## Code of Conduct

Participation in this open source project is governed by the SPR Open Source
Code of Conduct, which outlines expectations for participation in SPR-managed
open source communities and steps for reporting unacceptable behavior. We are
committed to providing a welcoming and inspiring community for all. People
violating this code of conduct may be banned from the community.

See the `CODEOFCONDUCT.md` file for the full code of conduct. 


## License

This open source project is licensed under the terms of the [Apache 2.0
license][APACHE]. See the `LICENSE` file. Additional, non-authoritative
information about the license can be found at [Choose a License][CHOOSE], [Open
Source Initiative][OSINIT], and [TLDRLegal][TLDR]. 



[AAC]:    https://developer.android.com/topic/libraries/architecture/index.html
[APACHE]: https://opensource.org/licenses/Apache-2.0
[CHOOSE]: https://choosealicense.com/licenses/apache-2.0/
[GUIDE]:  https://developer.android.com/topic/libraries/architecture/guide.html
[MCHADO]: http://aplus.rs/2017/much-ado-about-ios-app-architecture/
[MVX]:    https://medium.com/ios-os-x-development/ios-architecture-patterns-ecba4c38de52
[OSINIT]: https://opensource.org/licenses/Apache-2.0
[TLDR]:   https://tldrlegal.com/license/apache-license-2.0-%28apache-2.0%29
