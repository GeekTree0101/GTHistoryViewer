# GTHistoryViewer

###### UINavigationController navigation stack viewer, built on Texture and written in Swift

## Feature
- Export to Cocoapod
- Test code
- Travis CI
- Support Animation
- Refactoring for Improve usability
- Fix unnatural offset moving bug

## Installation
Coming soon :)

## Usage
### Register gesture recognizer
###### register on view controller [Recommend]
```swift
    override func viewDidLoad() {
        super.viewDidLoad()
        GTHistoryViewer.shared.registGesture(view: self.view)
    }
```

###### register on app delegate [Feature]
```swift
        func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // ... etc

        GTHistoryViewer.shared.registGlobalGesture()
        return true
    }
```

###### unregister gesture
```swift
   // if you registered gesture on app delegate, view parameter value must be nil
   GTHistoryViewer.shared.unregistGesture(view: self.view) // or nil (if yo)
```

### Override didMove on view controller
###### automatically check stack and prepare preview
```swift
    override func didMove(toParentViewController parent: UIViewController?) {
        GTHistoryViewer.shared.didMove(self, parent: parent)
        super.didMove(toParentViewController: parent)
    }
```

### Update Attribute [Customizing UI]
###### [1]: close viewer duration
###### [2]: update preview shadow attribute
###### [3]: update preview image attribute
```swift
    GTHistoryViewer.shared
        .updateFadeOutDurationAfterPush(0.5) // [1]
        .updateShadowAttribute({ shadowAttr in // [2]
            shadowAttr.shadowColor = .gray
            shadowAttr.shadowOffset = .init(width: 1.0, height: 1.0)
            shadowAttr.shadowOpacity = 1.0
            shadowAttr.shadowRadius = 1.0
        })
        .updatePreviewAttribite({ previewAttr in // [3]
            previewAttr.frameColor = .gray
            previewAttr.previewBorderWidth = 1.0
            previewAttr.previewCornerRadius = 2.0
        })
```

