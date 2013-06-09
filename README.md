[![Build Status](https://travis-ci.org/ishkawa/ISRefreshControl.png?branch=master)](https://travis-ci.org/ishkawa/ISRefreshControl)

## Requirements

iOS 4.3 or later

## Usage 

1. add files under `ISRefreshControl/` to your project.
2. import `ISRefreshControl.h`. 

Usage of `ISRefreshControl` is almost the same as that of `UIRefreshControl`.  
set `refreshControl` of `UITableViewController` in `viewDidLoad`.

```objectivec
self.refreshControl = (id)[[ISRefreshControl alloc] init];
[self.refreshControl addTarget:self
                        action:@selector(refresh)
              forControlEvents:UIControlEventValueChanged];
```

or just call `addSubview:`

```objectivec
UIScrollView *scrollView = [[UIScrollView alloc] init];
ISRefreshControl *refreshControl = [[ISRefreshControl alloc] init];
[scrollView addSubview:refreshControl];
[refreshControl addTarget:self
                   action:@selector(refresh)
         forControlEvents:UIControlEventValueChanged];
```

or set "Refreshing" of `UITableViewController` "Enabled" on storyboard.

```objectivec
[self.refreshControl addTarget:self
                        action:@selector(refresh)
              forControlEvents:UIControlEventValueChanged];
```

## How it works

#### iOS6

works as real `UIRefreshControl`.  
the constructor of `ISRefreshControl` returns an instance of `UIRefreshControl`.

#### iOS5 and iOS4

imitates `UIRefreshControl`.
`ISRefreshControl` sends `UIControlEventValueChanged` when content offset of `UITableView` overs threshold.
`UITableViewController` is extended to send content offset to `ISRefreshControl`.

## Installing

The best way to Install ISRefreshControl is by using CocoaPods.
```
pod 'ISRefreshControl', '~> 1.4.1'
```

### Without CocoaPods 

- install [ISMethodSwizzling](https://github.com/ishkawa/ISMethodSwizzling).
- add files under `ISRefreshControl/` to your project.
- add `QuartzCore.framework` to "Link Binary With Libraries" (in "Build Phases").

## Change log

see [CHANGELOG.md](https://github.com/ishkawa/ISRefreshControl/blob/master/CHANGELOG.md).

## License

Copyright (c) 2013 Yosuke Ishikawa

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
