# TAAnalytics

This is an opiniated analytics framework wrapper that you can use for your product analytics needs. It abstracts away the underlying analytics platform (e.g. Firebase/MixPanel/Amplitude/etc) while providing several nice benefits:

1. It supports an opiniated standard event structure, so that you'll have more sane event names (vs `foo_clicked`, `tap_bar`, `baz`)
2. It provides a common interface so that you can send the same event to multiple adaptors, minimizing bugs.
3. It has checks & workarounds for common implementation bugs with , enforcing a more clean dataset (aka your BIs will thank you). For example:   
  - Trimming event names & property keys/values in Firebase. If they are too long, Firebase will just silently stop sending them.
  - Warns you about reserved `event_names`. If you happen to use a reserved `event_name` (e.g. `app_background` in Firebase), most analytics adaptors won't send the event at at all.
  - sending an unsupported type as a parameter value would result in the event not being sent at all. For example, Firebase doesn't support sending Swift Int values, they need to be wrapped in an `NSNumber` first.


## Analytics Adaptors

When you initialize an `TAAnalytics` object you can pass it an array of adaptors that will consume those events & user property changes. These adaptors forward the data to the underlying analytics platform.

Adaptors can be implemented by implementing the `AnalyticsAdaptor` protocol that provides mecanishms for guarding against starting it in Xcode/TestFlight/prod, character limits and others. 

These adaptors are now available:

 Adaptor Name | Details | Location
 --- | --- | --- 
OSLogAnalyticsAdaptor | Log all tracked events & user properties to OSLog | inside this library
EventEmitterAdaptor | Provides streams for any events sent & user properties set. | inside this library
AmplitudeAnalyticsAdaptor | https://amplitude.com | https://github.com/TechArtists/ios-analytics-adaptor-amplitude
FirebaseAnalyticsAdaptor | http://firebase.google.com | https://github.com/TechArtists/ios-analytics-adaptor-firebase
CrashlyticsAnalyticsAdaptor | Logs all tracked events & user properties to Crashlytics. | https://github.com/TechArtists/ios-analytics-adaptor-firebase 
HeapAnalyticsAdaptor | https://www.heap.io | https://github.com/TechArtists/ios-analytics-adaptor-heap
MixPanelAnalyticsAdaptor | https://www.mixpanel.com | https://github.com/TechArtists/ios-analytics-adaptor-mixpanel
PendoAnalyticsAdaptor | https://www.pendo.io | https://github.com/TechArtists/ios-analytics-adaptor-pendoio
SegmentAnalyticsAdaptor | https://www.segment.com | https://github.com/TechArtists/ios-analytics-adaptor-segment
AppsFlyerAnalyticsAdaptor | https://www.appsflyer.com | https://github.com/TechArtists/ios-analytics-adaptor-appsflyer
AdjustAnalyticsAdaptor | https://www.adjust.com | https://github.com/TechArtists/ios-analytics-adaptor-adjust

### Multiple Adaptors

As a business you might use different adaptors for these analytics providers. 

For example, the product team might want to see all events in Amplitude/MixPanel as they have easier self-serve dashboards, while the data engineering team would like to see the events in Firebase, to manipulate them directly into BigQuery.
The marketing team would also like some events to make it to an MMP like AppsFlyer/Adjust, so that they can use them as conversion actions for digital marketing.

Here's an example:

```
    let analytics = TAAnalytics(config: TAAnalyticsConfig(analyticsVersion: "1.0", 
                    adaptors: [
                        OSLogAnalyticsAdaptor(), 
                        EventEmitterAdaptor(),
                        MixPanelAdaptor(mixpanelToken:"TOKEN_GOES_HERE"),
                        FirebaseAnalyticsAdaptor(),
                        CrashlyticsAnalyticsAdaptor(isRedacted:false) 
                    ]
                  ))

    let mmpAnalytics = TAAnlytics(config: TAAnalyticsConfig(analyticsVersion: "1.0",
                        adaptors: [
                        OSLogAnalyticsAdaptor()
                        AppsflyerAnalyticsAdaptor(devKey: "DEV_KEY", appleAppID: "APP_ID")
                    ]
                  ))
    analytics.track(.FIRST_OPEN)
    
    analytics.track(.PURCHASE)
    mmpAnalytics.track(.PURCHASE)
```




# Event Structure

You can send any custom events you want or make use of the default ones. The more default or commons ones you use between apps, the easier it is for the data team to do cross-app comparisons.

## Custom Events

`EventAnalyticsModel` is the underlying type for modelling all events, alongside `AnalyticsBaseParameterValue`. The latter is used to provide compile time guarantees that the parameters you are sending will reach the underlying analytics platform. 

For example, a common mistake is to send a Swift Int/Double as a parameter value directly to Firebase Analytics, that will cause the event to not be sent altogether. It needs to be wrapped in an ObjC NSNumber first. 

Another common mistake is to go over the maximum allowed number of characters for the event name, parameter name or parameter value, that will then cause either the parameter to be dropped or the full event, leaving you with no data to analyse.

This libary provides handy wrappers for all these platform specific quirks, as well as other benefits.

The main function to send events is `#track(event: EventAnalyticsModel,params: [String: (any AnalyticsBaseParameterValue)?]? = nil,logCondition: EventLogCondition = .logAlways`

`EventLogCondition` specifies if the event should be sent always, just once per app session (e.g. `my_app_open`) or just once per lifetime (e.g. `my_first_open`)


For example: 

```
public extension EventAnalyticsModel {
    static let MY_FIRST_OPEN  = EventAnalyticsModel("my_first_open")
    static let MY_COLD_APP_LAUNCH =  EventAnalyticsModel("my_cold_app_launch")
    static let MY_APP_FOREGROUND = EventAnalyticsModel("my_app_foreground")
...
}

func applicationWillEnterForeground(_ application: UIApplication) {
    // this will be sent each time the app goes to the foreground
    analytics.track(.MY_APP_FOREGROUND, ["hello":"world"])
    // this will be sent only once per app session cold launch. Fast background/foreground cycles won't sent this again, but force quitting the app & opening will trigger it again.
    analytics.track(.MY_COLD_APP_LAUNCH, logCondition:.logOnlyOncePerAppSession)
    // this will only be sent once for the app
    analytics.track(.MY_FIRST_OPEN, logCondition:.logOnlyOncePerLifetime)
}
```


## Custom User Properties

`EventAnalyticsModel` is the underlying type for modelling all events, alongside `AnalyticsBaseParameterValue`. The latter is used to provide compile time guarantees that the parameters you are sending will reach the underlying analytics platform. 

It provides length checks for both the property name as well as the value. 

```
public extension EventAnalyticsModel {
    static let FAVORITE_SPORTS_TEAM =  EventAnalyticsModel("favorite_sports_team")
}
...
    analytics.set(userProperty: .FAVORITE_SPORTS_TEAM, to: "Mars")

```

Note that all user properties are also saved to user defaults so that you can read them at runtime. By default, most analytics platforms do not allow you to read the user property data as well. 


## Our First Open

While most analytics platforms automatilly collect their own `first_open` event, this is not very useful for your specific app. For the data team, having a `first_open` event with more app specific data would be beneficial for easier segmentation down the line.

This library provides an easy way to send an `our_first_open` event & be able to customize with multiple parameters that make sense for your app. For example, if you are an app that helps the elderly, it might make sense to be able to segment installs by dark/light mode appearance as well as the font size selected. 

When you `start()` the SDK, there is an optional `firstOpenParameterCallback` that you can use to be able to customize these parameters at runtime.

## Automatically Collected Events

 Event Name | Parameter Name & Type | Comments 
 --- | --- | --- 
 `app_version_update`  | `from_version:String` | previous `CFBundleShortVersionString`
|            | `from_build:String` | previous `CFBundleVersion`
|            | `to_version:String` | current `CFBundleShortVersionString`
|            | `to_build:String` | current `CFBundleVersion`
 `os_version_update`  | `from_version:String` | previous version in SemVer format
|            | `to_version:String` | current version in SemVer format

## Automatically Set User Properties

 User Property Name | Value | Comments 
 --- | --- | --- 
 `analytics_version`  | SemVer | the version of the analytics standard the app is using, this versioning should be based on an internal document used by the product, data & engineering team. Use this to communicate with your data team when you've implemnted version Foo that has all the events & logic, as documented.
 `app_open_count`  | Int | how many times the app was opened. A simple background-foreground cycle would increment this
 `app_cold_launch_count` | Int | how many times the app was started from 0. For example, a simple background-foreground cycle won't increment this, but a force quit & re-open would 

### Predefined Install User Properties

This library provides multiple user properties that can be set only once, at install. They are all prefixed with `install_%`, so that it's 
obvious to the data team that the values do not change, they are fixed from install time.

You can configure what install user properties you want to be set from the configuration.

                INSTALL_DATE, .INSTALL_VERSION, .INSTALL_PLATFORM_VERSION, .INSTALL_IS_JAILBROKEN, .INSTALL_UI_APPEARANCE, .INSTALL_DYNAMIC_TYPE
                
                
 User Property Name | Value | Comments 
 --- | --- | --- 
 `install_date`  | String | In ISO 8601 format (YYYY-MM-DD) 
 `install_version`  | String | The `CFBundleShortVersionString` from install
 `install_os_version` | String | Semver
 `install_is_jailbroken` | BoolString |  
 `install_ui_appearance` | <light, dark, unknown, unspecified> | Based on `UIUserInterfaceStyle` 
 `install_dynamic_type` | <Unspecified, XS, S, M, L, XL, XXL, XXXL, A11Y-M, A11Y-L, A11Y-XL, A11Y-XXL, A11Y-XXXL> |  `L` is the default one, set as 100%. Based on `UIContentSizeCategory` 


## Handy Methods

You can make use several methods that tell you the install age of the user, so that you can make decisions based on it:

- `loadCount`, how many times the app has been loaded
- `isFirstOpen`, if it's the very first open
- `installAgeRelativeDays`, the number of days since the app was installed. Age 0 means it's within the first 24h of it being installed
- `installAgeLocalizedCalendarDays`, the number of calendar days since the app was installed. Age 0 means that it's the same day. If a user installs the app at 23:59:59 UTC, 1 minute later this `installAgeCalendar` will be 1.


## Predefined Events

Besides using custom events, you can make use of the following predefined events and adopt it (or parts of it) as you internal standard.

### Onboarding & Account Signup

Minimal events for sending `onboarding_{enter,exit}` events and `account_signup_{enter,exit}` events.


 Event Name | Parameter Name & Type | Comments 
 --- | --- | --- 
 `onboarding_enter` |  | 
 `onboarding_exit` |  | 
 `account_signup_enter` | `method:Enum = {email, apple, google, facebook, <custom>}`  | The signup method chosen by the user
 `account_signup_exit` | `method:Enum = {email, apple, google, facebook, <custom>}`  | The signup method chosen by the user

### App Lifecycle

 Event Name | Parameter Name & Type | Comments 
 --- | --- | --- 
 `app_open`  | `is_cold_launch:Bool` | 
 `app_close` | `view_name:String?` | last view shown before the app was closed
|            | `view_type:String?` | 
|            | `group_name:String?` | 
|            | `group_order:String?` | 
|            | `group_stage:String?` | 
 
 User Property Name | Value | Comments 
 --- | --- | --- 
 `app_open_count`  | Int | how many times the app was opened. A simple background-foreground cycle would increment this
 `app_cold_launch_count` | Int | how many times the app was started from 0. For example, a simple background-foreground cycle won't increment this, but a force quit & re-open would 

### Debug & Error

 Event Name | Parameter Name & Type | Comments 
 --- | --- | --- 
 `debug`  | reason: String | Use when engineers want to test in production the occurences of any debug events. It's not an error, merely used for debugging.
 |  | `*` | 
 `error`  | reason: String | a developer reason about what triggered the error state (e.g. `couldnt find any valid JWT token`)
 | | `error_domain: String?` | the domain of underlying NSError that triggered this error state
  | | `error_code: Int?` | the code of underlying NSError that triggered this error state
  | | `error_description: String?` | the description of underlying NSError that triggered this error state
  | | `*` | any other parameters that the engineer might find useful
`error_corrected`  | reason: String | An error that has been corrected. This should be the same reason as the above `error` event.
 | | `error_domain: String?` | 
  | | `error_code: Int?` | 
  | | `error_description: String?` | 
  | | `*` | 


### UI Interactions

After using multiple SDKs that codeless UI analytics, I much prefer an explicit event sent from the code. Far more reliable, easier to test & breaks less often.

Instead of standardizing on having many events such as `foo_clicked`, `tapped_foo`, `shown_bar` this library uses 2 generic events for manually tracking all UI events: `ui_view_show` & `ui_button_tap`. 

They both come with a rich set of parameters that can be customized for almost all use cases.  

 Event Name | Parameter Name & Type | Comments 
 --- | --- | --- 
 `ui_view_show` | `name:String` | the name of the view 
|                | `type:String?`, optional | the type of the view. Useful when you want to distuinguish between multiple states of the same view. For example, showing a "contacts list" view and when there are no Contacts permissions granted, you can set the type to "no permissions". That way you can split the `name=contacts list` by the `type` to see how many see the "no permissions" view.
|                | `group_name:String?`, optional | the name of the group the view belongs to, if any. A group is a sequence of multiple views/screens that encompass a business funnel (e.g. "onboarding", "reset password"). Marking the group makes it easy for the data team to analyse which one is which.
|                | `group_order:Int?`, optional | the index inside the group of this view 
|                | `group_stage:Enum? = {enter, intermediate, exit}`, optional | if this specific view is the first one of the group, last one or any other one 
|                | `secondary_name:String?`, optional | the name of the secondary view that shown inside/on top/related to a normal one. For example, showing a "Passwords needs to have at least 8 character" warning label on the "reset password" screen.
|                | `secondary_type:String?`, optional | same for the above
 `ui_button_tap` | `name:String` | the name of the button. Try to use a symbolical name, not the localized one (e.g. "sign up", not "sign up" vs "Sign-up" vs "Register" vs "Inscribirse"). Using the same symbolical name for a longer period of time makes it easier to analyse long term trends.
|                | `extra:String?`, optional | anything extra you would like to attach to this button tap.
|                | `order:Int?`, optional | the order of this button, if applicable. For example, if you want to specify that the user tapped the 5th button in a list  
|                | `view_name:String` | the name of the view where the button was tapped |
|                | `view_type:String?` |  |
|                | `group_name:String?`, optional |  |
|                | `group_order:String?`, optional |  |
|                | `group_stage:String?`, optional |  |
|                | `secondary_view_name:String?` | the name of the secondary view where this button was tapped, if any |
|                | `secondary_view_type:String?` |  |

The library has specific types to make handling these easier.

There are two main types for views:

 - `ViewAnalyticsModel`, that uou can use to model full views/screens. For example, showing the "contacts list" in a phone app.
 - `SecondaryViewAnalyticsModel`, that can be used to model secondary views, that are attached to a "main" view from above. For example, a secondary view would be a popup confirming deleting a contact from the contact list or in a "change password" main view, it could be a label that shows that the new password is invalid (e.g. "invalid password combination, it needs at least 8 characters".)
 
For main views, the library also provides a handy way for tracking when transient views get stuck.  By providing  a `stuckTimeout`, if that specific view hasn't been transitioned out by another main view within that time, it will send an `error reason=stuck on ui_view_show` event. For example, this is useful to track users that get stuck on a splash screen, a screen that should take at most 5 seconds to load. Once the view does get replaced, an `error_corrected` event will be sent with the total duration elapsed (e.g. 7 seconds), so that you can better measure how many users get stuck altogether vs how many false positives events there are because the `stuckTimeout` is too small.

```
let splashView = ..

// the splash screen does an HTTPS "is alive" check with the server. It should finish fast
analytics.track(viewShow: splashView, stuckTimeout: 5) 

// 5 seconds pass
// event sent with event_name="error", param["reason"]="stuck on ui_view_show", param["duration"]=5.0, param["view_name"]="splash"

// 2 more seconds pass, we finally load in the main view
analytics.track(viewShow: mainView) 
// event sent with event_name="error_corrected", param["reason"]="stuck on ui_view_show", param["duration"]=5.0, param["view_name"]="splash"

```

### Permissions & ATT Tracking

As with other parts, this library standardizes on a simple way of tracking user permission, via the above `ui_view_show` event.

 Event Name | Parameter Name & Type | Comments 
 --- | --- | --- 
 `ui_view_show` | `name="permission"`  | 
|               | `type:Enum = {push notifications, att, location, microphone, <custom>}` | the specific permission
 `ui_button_tap` | `name=Enum = {allow, dont allow, <custom>`  | Either use the standard allow/dont allow terminilogy if it's a simple yes/no pop-up or provide a custom string. The former makes it easier on the data side.
|            | `view_name="permission"`  | 
|            |    `view_type:Enum = {push notifications, att, location, microphone, <custom>}` | the specific permission

For ATT specifically, you can also make use of a dedicated method that tracks these events explicitly too. ATT is important enough that it warrants its own event.

 Event Name | Parameter Name & Type | Comments 
 --- | --- | --- 
 `att_prompt_not_allowed` |  | 
 `att_prompt_show` |   | it also sends a corresponding `ui_view_show name=permission type=att` event for consistency
 `att_prompt_tap_allow` | `advertising_id:String`  | it also sends a corresponding `ui_button_tap` event for consistency
 `att_prompt_tap_deny` |   | 


### Paywall

 Event Name | Parameter Name & Type | Comments 
 --- | --- | --- 
 `paywall_enter` | `placement:String`  | the trigger why the placement was shown
|               | `id:String?` | the id of the paywall
|               | `name:String?` | the name of the paywall
 `paywall_purchase_tap` | `placement:String`  | the trigger why the placement was shown
|               | `button_name:String` | symbolic name for the button 
|               | `product_id:String` | the id of the store product being purchased
|               | `paywall_id:String?` | the id of the paywall
|               | `paywall_name:String?` | the name of the paywall
 `paywall_exit` | `placement:String`  | the trigger why the placement was shown
|               | `id:String?` | the id of the paywall
|               | `name:String?` | the name of the paywall
|               | `reason:Enum = {closed paywall, cancelled payment confirmation, new subscription, restored subscription, other <custom>}` | the reason the paywall has ben exit


Note that calling the specific `trackPaywallEnter()` method will track both a `paywall_enter` event as well as a corresponding a `ui_view_show name="paywall" type=<placement>` event for consistency. Similar for `trackPaywallPurchaseTap()` that also triggers an `ui_button_tap view_name="paywall" type=<placement>`.


### Subscription Starts

 Event Name | Parameter Name & Type | Comments 
 --- | --- | --- 
 `subscription_start_intro` |   | a subscription that start with an introductory offer: trial, pay as you go, pay up front
|               |  `placement:String`  | the placement
|               | `product_id:String` | the id of the product
|               | `type:Enum = {trial, paid intro pay as you go, paid intro pay up front, paid regular, <custom>}` | type of subscription
|               | `paywall_id:String?` | the id of the product
|               | `paywall_name:String?` | the id of the product
|               | `value:Float` | 
|               | `price:Float` | 
|               | `currency:String` | 
|               | `quantity:1` | 
`subscription_start_paid_regular` | same as above  | subscription that is paid from the start
`subscription_start_new` | same as above  | either one of the two above
`subscription_start_restore` | same as above  | subscription that is restored

### Engagement

You can track engagement, as defined by whatever you consider engagement in your app via these 2 built-in events:

 Event Name | Parameter Name & Type | Comments 
 --- | --- | --- 
 `engagement` | `name:String`  | why this is considered engagement. For example, in a fitness app it might be "start workout", "log set" or "complete workout".
 |    | `view_name:String?`  | the last view shown before this engagement was fired.
 |    | `view_type:String?`  | the last view shown before this engagement was fired.
 |    | `view_group_name:String?`  | the last view shown before this engagement was fired.
 |    | `view_group_order:String?`  | the last view shown before this engagement was fired.
 |    | `view_group_stage:String?`  | the last view shown before this engagement was fired.
 `engagement_primary` | same as above  | same as above, but use this for engagements that you consider are the primary success driver of your app (e.g. completing a workout)


Note that sending an `engagement_primary` event will also send an `engagement` event for consistency.




# Configuration points

## Logging with TALogger

`TAAnalytics` includes a built-in logging system using OSLog, allowing for structured and efficient logging.

By default, logs will be sent via OSLog. Clients can override this to forward logs elsewhere (e.g., a server or a file).

**Custom Log Handler**

```swift
TALogger.activeLogHandler = { message, level in
    MyCustomLogger.shared.writeLog("[\(level)] \(message)")
}
```

Once set, TALogger.log(...) inside the package will use the custom logging system.




# TODO:

- ATT 
- Config automaticallyTrackedEventsPrefixConfig in TAAnalyticsConfig does not work for events
