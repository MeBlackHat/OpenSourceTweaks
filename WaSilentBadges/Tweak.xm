#import <SpringBoard/SBIcon.h>

@interface WAMessage : NSObject
@property (nonatomic,retain) NSString* fromJID; 
@end

@interface WAMessageNotificationCenter
- (_Bool)isChatWithJIDMuted:(id)arg1;
- (id)initWithXMPPConnection:(id)arg1 userDefaults:(id)arg2 chatStorage:(id)arg3 pushPayloadDecrypter:(id)arg4;
@end

static NSString *plistPath = @"/var/mobile/Library/Preferences/com.meblackhat.wasilentbadges.plist";
static WAMessageNotificationCenter *checkMuted;
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

%hook WAMessageNotificationCenter
- (id)initWithXMPPConnection:(id)arg1 userDefaults:(id)arg2 chatStorage:(id)arg3 pushPayloadDecrypter:(id)arg4{
	return checkMuted = %orig;
}
%end

%hook WAChatSessionTransaction
- (void)trackReceivedMessage:(id)arg1{
	%orig;
	dispatch_async(dispatch_get_main_queue(), ^{
		WAMessage *msg = arg1;
		if([checkMuted isChatWithJIDMuted:msg.fromJID]){
			long long crntBadges = getBadges() + [icon badgeValue] + 1;
			writeBadges([NSString stringWithFormat:@"%lld", crntBadges]);
			[[UIApplication sharedApplication] setApplicationIconBadgeNumber:crntBadges];
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