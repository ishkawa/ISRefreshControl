#import "Kiwi.h"
#import "ISRefreshControl.h"
#import "ISGumView.h"
#import "ISScalingActivityIndicatorView.h"
#import "ISMockScrollView.h"
#import "UIColor+ISRefreshControl.h"

SPEC_BEGIN(ISRefreshControlSpec)

if ([UIRefreshControl class]) {
    describe(@"ISRefreshControl on iOS6+", ^{
        __block ISRefreshControl *refreshControl;
        
        beforeEach(^{
            refreshControl = [[ISRefreshControl alloc] init];
        });
        
        context(@"when created", ^{
            it(@"is member of UIRefreshControl", ^{
                [[refreshControl should] beMemberOfClass:[UIRefreshControl class]];
            });
        });
    });
} else {
    describe(@"ISRefreshControl on iOS5", ^{
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
        
        context(@"when newtral and tracking", ^{
            beforeEach(^{
                scrollView.contentOffset = CGPointMake(0.f, 0.f);
                scrollView.tracking = YES;
            });
            
            it(@"begins refreshing and sends UIControlEventValueChanged on going over threshold", ^{
                [[refreshControl should] receive:@selector(beginRefreshing)];
                [[refreshControl should] receive:@selector(sendActionsForControlEvents:) withArguments:theValue(UIControlEventValueChanged)];
                
                scrollView.contentOffset = CGPointMake(0.f, -200.f);
            });
        });
    });
}

SPEC_END
