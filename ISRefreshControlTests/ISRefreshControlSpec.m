#import "Kiwi.h"
#import "ISRefreshControl.h"
#import "ISGumView.h"
#import "ISScalingActivityIndicatorView.h"
#import "ISMockScrollView.h"
#import "UIColor+ISRefreshControl.h"

static NSString *const ISContentOffsetKey = @"contentOffset";

SPEC_BEGIN(ISRefreshControlSpec)

describe(@"ISRefreshControl", ^{
    __block ISRefreshControl *refreshControl;
    __block ISGumView *gumView;
    __block ISScalingActivityIndicatorView *indicatorView;
    __block ISMockScrollView *scrollView;
    
    beforeEach(^{
        refreshControl = [[ISRefreshControl alloc] init];
        gumView = [refreshControl performSelector:@selector(gumView)];
        indicatorView = [refreshControl performSelector:@selector(indicatorView)];
        
        scrollView = [[ISMockScrollView alloc] init];
        [scrollView addSubview:refreshControl];
    });
    
    context(@"when created", ^{
        it(@"has gumView", ^{
            [gumView shouldNotBeNil];
        });
        
        it(@"contains gumView", ^{
            [[[refreshControl subviews] should] contain:gumView];
        });
        
        it(@"gumView is visible", ^{
            [[theValue(gumView.hidden) should] beNo];
        });
        
        it(@"has indicatorView", ^{
            [indicatorView shouldNotBeNil];
        });
        
        it(@"contains indicatorView", ^{
            [[[refreshControl subviews] should] contain:indicatorView];
        });
        
        it(@"indicatorView is invisible", ^{
            [[theValue(indicatorView.hidden) should] beYes];
        });
    });
    
    context(@"when newtral offset", ^{
        beforeEach(^{
            scrollView.contentOffset = CGPointMake(0.f, 0.f);
        });
        
        it(@"sends UIControlEventValueChanged on going over threshold", ^{
            [[refreshControl should] receive:@selector(sendActionsForControlEvents:) withArguments:theValue(UIControlEventValueChanged)];
            
            scrollView.tracking = YES;
            scrollView.contentOffset = CGPointMake(0.f, -200.f);
        });
    });
});

SPEC_END
