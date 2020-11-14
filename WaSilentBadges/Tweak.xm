#import <SpringBoard/SBIcon.h>

@interface WAChatSession : NSObject
@property(nonatomic) short sessionType;
@end

@interface WAMessage : NSObject
@property(readonly, nonatomic) WAChatSession *chatSession;
@property (nonatomic,retain) NSString* fromJID;
@end

static NSString *plistPath = @"/var/mobile/Library/Preferences/com.meblackhat.wasilentbadges.plist";
static SBIcon *icon;

static void writeBadges(NSString *value){
	NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:plistPath];
	NSMutableDictionary *mutableDict = dict ? [dict mutableCopy] : [NSMutableDictionary dictionary];
	[mutableDict setValue:value forKey:@"badgeValue"];
    [mutableDict writeToFile:plistPath atomically:YES];	
}

static long long getBadges(){
	NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:plistPath];
	NSMutableDictionary *mutableDict = dict ? [dict mutableCopy] : [NSMutableDictionary dictionary];
	return [[mutableDict objectForKey:@"badgeValue"] longLongValue];
}

%hook SBIcon
-(id)init{
	return icon = %orig;
}
%end

%hook WAChatSessionTransaction
- (void)trackReceivedMessage:(id)arg1{
	%orig;
	dispatch_async(dispatch_get_main_queue(), ^{
		WAMessage *msg = arg1;
		if(msg.chatSession.sessionType != 3){
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
			long long crntBadges = getBadges() + [icon badgeValue] + 1;
			writeBadges([NSString stringWithFormat:@"%lld", crntBadges]);
			[[UIApplication sharedApplication] setApplicationIconBadgeNumber:crntBadges];
			});
		}
	});
}
%end

%hook WhatsAppAppDelegate
- (_Bool)application:(id)arg1 didFinishLaunchingWithOptions:(id)arg2{
	writeBadges(@"0");
	return %orig;
}
- (void)applicationDidBecomeActive:(id)arg1{
	%orig;
	writeBadges(@"0");
}
%end
