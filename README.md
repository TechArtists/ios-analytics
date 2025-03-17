# TAAnalytics

This is an opiniated analytics framework wrapper that you can use for your product analytics needs and abstracts away the underlyin analytics platform (e.g. Firebase/MixPanel/Amplitude/etc).

It serves a couple of important points:

    1. It supports an opiniated standard event structure, so that you'll have more sane event names (vs `foo_clicked`, `tap_bar`, `baz`)
    2. It provides a common interface so that you can send the same event to multiple consumers, minimizing bugs.
    3. It has workarounds for common bugs, enforcing a more clean dataset (aka your BIs will thank you).
 

# Standard Event Structure

- `ui_view_show` with `name`, `type`, `group_name`, `group_order`, `group_stage` & `parent_view_{all the before}`
- `ui_button_tapped` with `name`, `extra`, `order` & the above view parameters prefixed as `view_%`
- `error_`
- `permission_`
- easy variables for app open counts, is first install, is update, is a new session, etc.


# Common Interface

One common interface to send. Most analytics consumers have the same capabilities, where you can send events with custom parameters & set user properties.

```
1. install_device_language: en_US
    -> set once before `ta_first_open`.
    -> want to re-set in FB at each app open, but read it from UserDefaults


    analyics.start(
        customInitialUserProperties: {
            analytics.set(.install_device_language, value: getLanguage())
        }
    )

    on the 1st run, we do Firebase.set("install_device_language", "en")
    on all the other runs, we do Firebase.set("install_device_language", UserDefaultsCache.get("install_device_language"))

   
2. current_device_language: ro_RO
    -> set at each app launch by the client
    
    didFinishLaunching() {
        analyics.set(.current_device_language, value: getLanguage())
    }
    
    no need for TA to do anything, because the client always sends it.
    

3. login_status: welcome, onboarding step {1,2,3}, logged in  (aka random user property set sporadically)
        didFinishLaunching() {
            // do nothing
        }
        
        func moveToOnboardingStep1() {
            analyics.set(.login_status, value: "onboarding step 1")
        }
        
        func didLogin() {
            analyics.set(.login_status, value: "logged in")
        }    
    
    what do we do on the next app restart?
        do we re-set the UP with the last value for the `.login_status` UP, like we'd do for install UPs?
        we can't re-set all the UPs at each app launch, what if the user no longer cares about the `.login_status` one and has removed it from the code?
        or what if they hit the 20/25 UP limit and FB starts overwiting them, with the last one winning? Us re-setting all of them at each startup would mess things up.
}
    
    
```


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

## Goodies

- send an event only once
- custom `ta_first_open` event that can be pre-set with all your parameters & custom user properties that are a right fit for your product
- strong defaults collected and set as user properties (e.g. dark/ligt mode support, install_version, text_size)


# Common Bugs

- Trimming event names & property keys/values in Firebase. If they are too long, Firebase will just silently stop sending them.
- Warns you about reserved `event_names`. If you happen to use a reserved `event_name` (e.g. `app_background`), most analytics consumers won't send it at all.
- sending an unsupported type as a parameter value would result in the event not being sent at all. For example, Firebase doesn't support sending Swift Int values, they need to be wrapped in an `NSNumber` first.


# TODO: 
- Config automaticallyTrackedEventsPrefixConfig in TAAnalyticsConfig does not work for events
