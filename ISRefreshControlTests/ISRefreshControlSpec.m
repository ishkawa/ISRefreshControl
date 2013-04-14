#import "Kiwi.h"
#import "ISRefreshControl.h"
#import "ISGumView.h"
#import "ISScalingActivityIndicatorView.h"
#import "ISMockScrollView.h"
#import "UIColor+ISRefreshControl.h"
#import "ISRefreshControl+Public.h"

SPEC_BEGIN(ISRefreshControlSpec)

#ifdef IS_TEST_FROM_COMMAND_LINE
BOOL shouldRunOS6Tests = NO;
#else
BOOL shouldRunOS6Tests = YES;
#endif

if ([UIRefreshControl class] && shouldRunOS6Tests) {
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
        
        context(@"state=normal", ^{
            beforeEach(^{
                refreshControl.refreshingState = ISRefreshingStateNormal;
            });
            
            context(@"tracking=YES", ^{
                beforeEach(^{
                    scrollView.tracking = YES;
                });
                
                it(@"is visible when it goes over threshold", ^{
                    scrollView.contentOffset = CGPointMake(0.f, 100.f);
                    scrollView.contentOffset = CGPointMake(0.f, -100.f);
                    [[theValue(refreshControl.hidden) should] beNo];
                });
                
                it(@"is visible when it goes over threshold without tracking", ^{
                    scrollView.contentOffset = CGPointMake(0.f, 100.f);
                    scrollView.tracking = NO;
                    scrollView.contentOffset = CGPointMake(0.f, -100.f);
                    [[theValue(refreshControl.hidden) should] beYes];
                });
                
                it(@"sends UIControlEventValueChanged on going over threshold", ^{
                    [[refreshControl should] receive:@selector(sendActionsForControlEvents:) withArguments:theValue(UIControlEventValueChanged)];
                    scrollView.contentOffset = CGPointMake(0.f, -200.f);
                });
                
                it(@"begins refreshing on going over threshold", ^{
                    [[refreshControl should] receive:@selector(beginRefreshing)];
                    scrollView.contentOffset = CGPointMake(0.f, -200.f);
                });
            });
            
            context(@"tracking=NO", ^{
                beforeEach(^{
                    scrollView.tracking = NO;
                });
                
                it(@"does not send UIControlEventValueChanged on going over threshold", ^{
                    [[refreshControl shouldNot] receive:@selector(sendActionsForControlEvents:) withArguments:theValue(UIControlEventValueChanged)];
                    scrollView.contentOffset = CGPointMake(0.f, -200.f);
                });
                
                it(@"does not begin refreshing on going over threshold", ^{
                    [[refreshControl shouldNot] receive:@selector(beginRefreshing)];
                    scrollView.contentOffset = CGPointMake(0.f, -200.f);
                });
            });
        });
        
        context(@"state=refreshing", ^{
            beforeEach(^{
                refreshControl.refreshingState = ISRefreshingStateRefreshing;
            });
            
            context(@"dragging=NO", ^{
                beforeEach(^{
                    scrollView.dragging = NO;
                });
                
                it(@"receives addTopInsets", ^{
                    [[refreshControl should] receive:@selector(addTopInsets)];
                    scrollView.contentOffset = CGPointMake(0.f, 0.f);
                });
            });
            
            context(@"dragging=YES", ^{
                beforeEach(^{
                    scrollView.dragging = YES;
                });
                
                it(@"receives addTopInsets", ^{
                    [[refreshControl shouldNot] receive:@selector(addTopInsets)];
                    scrollView.contentOffset = CGPointMake(0.f, 0.f);
                });
            });
        });
        
        context(@"state=refreshed", ^{
            beforeEach(^{
                refreshControl.refreshingState = ISRefreshingStateRefreshed;
            });
            
            context(@"offset<0", ^{
                beforeEach(^{
                    scrollView.contentOffset = CGPointMake(0.f, -100.f);
                });
                
                it(@"is still refreshed", ^{
                    [[theValue(refreshControl.refreshingState) should] equal:theValue(ISRefreshingStateRefreshed)];
                });
            });
            
            context(@"offset>0", ^{
                beforeEach(^{
                    scrollView.contentOffset = CGPointMake(0.f, 100.f);
                });
                
                it(@"is normal", ^{
                    [[theValue(refreshControl.refreshingState) should] equal:theValue(ISRefreshingStateNormal)];
                });
            });
        });
        
        context(@"not under refreshing", ^{
            beforeEach(^{
                [refreshControl stub:@selector(isRefreshing) andReturn:theValue(NO)];
            });
            
            // beginRefreshing
            it(@"becomes refreshing  when beginRefreshing is called", ^{
                [[refreshControl should] receive:@selector(setRefreshingState:) withArguments:theValue(ISRefreshingStateRefreshing)];
                [refreshControl beginRefreshing];
            });
            
            it(@"indicator starts animating when beginRefreshing is called", ^{
                [[indicatorView should] receive:@selector(startAnimating)];
                [refreshControl beginRefreshing];
            });
            
            it(@"gumView shrinks when beginRefreshing is called", ^{
                [[gumView should] receive:@selector(shrink)];
                [refreshControl beginRefreshing];
            });
            
            // endRefreshing
            it(@"indicator does not stop animating when endRefreshing is called", ^{
                [[indicatorView shouldNot] receive:@selector(stopAnimating)];
                [refreshControl endRefreshing];
            });
        });
        
        context(@"under refreshing", ^{
            beforeEach(^{
                [refreshControl stub:@selector(isRefreshing) andReturn:theValue(YES)];
            });
            
            // beginRefreshing
            it(@"indicator does not start animating when beginRefreshing is called", ^{
                [[indicatorView shouldNot] receive:@selector(startAnimating)];
                [refreshControl beginRefreshing];
            });
            
            it(@"gumView does not shrink when beginRefreshing is called", ^{
                [[gumView shouldNot] receive:@selector(shrink)];
                [refreshControl beginRefreshing];
            });
            
            // endRefreshing
            it(@"becomes refreshed when endRefreshing is called", ^{
                [[refreshControl should] receive:@selector(setRefreshingState:) withArguments:theValue(ISRefreshingStateRefreshed)];
                [refreshControl endRefreshing];
            });
            
            it(@"subtracts top insets when endRefreshing is called", ^{
                [refreshControl stub:@selector(addedTopInset) andReturn:theValue(YES)];
                [[refreshControl should] receive:@selector(subtractTopInsets)];
                [refreshControl endRefreshing];
            });
            
            it(@"indicator stops animating when endRefreshing is called", ^{
                [[indicatorView should] receive:@selector(stopAnimating)];
                [refreshControl endRefreshing];
            });
        });
    });
}

SPEC_END
