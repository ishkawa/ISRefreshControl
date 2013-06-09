### 1.4.1

- fixed bug that `ISGumView.layer.fillColor` does not change when `ISRefreshControl.tintColor` changes.

### 1.4.0

- iOS 4.x support.
- improved many animations.
- added `QuartzCore.framework` to linked frameworks.
- fixed bug caused by `contentInset`.
- stops drawing when visible area is away from refresh control. #13

### 1.3.0

- avoided crash on stopAnimating if ISScalingActivityIndicatorView.superView is nil. #14
- improved initializer of `ISScalingActivityIndicatorView`.
- removed `QuartzCore.framewrok` from linked frameworks.
- removed `ISMethodSwizzling` from source files, and add it to dependencies.  
  (now, `ISMethodSwizzling` is available on [CocoaPods/Specs](https://github.com/CocoaPods/Specs).)

### 1.2.2

- fixed build for Travis CI.

### 1.2.1

- added `ISMethodSwizzling` to source files because [CocoaPods/Specs](https://github.com/CocoaPods/Specs) fails build  
  when dependencies contains unregistered podspec.

### 1.2.0

- added storyboard support.
- improved some animations.
- adjusted default `tintColor` of `ISGumView` and `ISScalingActivityIndicatorView`.
- added dropshadow for `ISGumView`.

### 1.1.1

- improved shrinking animtion.
- refactored managing indicatorView and gumView.

### 1.1.0

- added `tintColor` support.
- added UIAppearance support (tintColor only).

### 1.0.2

- delays updating `contentInset` to avoid setting invalid `contentInset`.

### 1.0.1

- fixed issue that view of nib was dismissed if `refreshControl` was set in `initWithCoder`.
- brings refreshControl to front when `beginRefreshin` and `endRefreshing`.

### 1.0.0

- hides `ISRefreshControl` when it appears by inertia.
- supported `UITableView` and `UIScrollView`. now, ISRefreshControl can be use by `addSubview:`. #2
