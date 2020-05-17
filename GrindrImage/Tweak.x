@interface _TtC7grindrx19ImageViewController : UIViewController
@property(nonatomic, copy) NSString *mediaHash;
@property(nonatomic) unsigned long long itemIndex;
- (void)viewDidLoad;
- (id)init;
- (id)mediaHash;
@end

static void saveImagesInLocalDirectory();
static NSString *ImageURL;
static NSTimeInterval timeInSeconds;
static NSString *fileName;

static void saveImagesInLocalDirectory()
{
	NSURL  *url = [NSURL URLWithString:ImageURL];
	NSData *urlData = [NSData dataWithContentsOfURL:url];
	UIViewController * controller = [[UIApplication sharedApplication] keyWindow].rootViewController;

	if (urlData)
    {
    	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory,fileName];
        [urlData writeToFile:filePath atomically:YES];
        
        NSString *msg = [NSString stringWithFormat:@"Location :- %@", filePath];
        UIAlertController * alert = [UIAlertController  alertControllerWithTitle:@"File Saved" 
		message:msg
		preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction* okButton = [UIAlertAction actionWithTitle:@"OK" 
		style:UIAlertActionStyleDefault 
		handler:^(UIAlertAction * action) {
			[alert dismissViewControllerAnimated:YES completion:nil];
		}];

		[alert addAction:okButton];
		[controller presentViewController:alert animated:YES completion:nil];

    }	
    else{
    	UIAlertController * alert = [UIAlertController  alertControllerWithTitle:@"Fialed to save the file." 
		message:@"Some erros occured or file with same name is already exist."
		preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction* okButton = [UIAlertAction actionWithTitle:@"OK" 
		style:UIAlertActionStyleDefault 
		handler:^(UIAlertAction * action) {
			[alert dismissViewControllerAnimated:YES completion:nil];
		}];

		[alert addAction:okButton];
		[controller presentViewController:alert animated:YES completion:nil];
    }
}

%hook _TtC7grindrx19ImageViewController
- (void)viewDidLoad{
	//This view load when we open the Image file fro the Chat.
	UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]
            initWithTarget:self
            action:@selector(handleLongPress:)];
            longPress.minimumPressDuration = 1.0;
            [self.view addGestureRecognizer:longPress];
	%orig;
}
%new 
- (void)handleLongPress:(UILongPressGestureRecognizer*)recognizer
{
	//Getting system time so we can have random file names :p
    timeInSeconds = [[NSDate date] timeIntervalSince1970];
	fileName = [NSString stringWithFormat:@"grinderImage%f.jpeg", timeInSeconds];
	//mediaHash is the file name which we want to save to lets append that to cnd URL
	NSString *mediaHashReal = [self mediaHash];
	ImageURL = [NSString stringWithFormat:@"https://cdns.grindr.com/grindr/chat/%@", mediaHashReal];
	
	//Creating a controller to show Alert with actions. 
	UIViewController * controller = [[UIApplication sharedApplication] keyWindow].rootViewController;
	UIAlertController * alert = [UIAlertController  alertControllerWithTitle:@"Save the image?" 
		message:nil
		preferredStyle:UIAlertControllerStyleAlert];

	UIAlertAction* yesButton = [UIAlertAction actionWithTitle:@"Yes" 
		style:UIAlertActionStyleDefault 
		handler:^(UIAlertAction * action) {
			//caliing the download image methods...
			saveImagesInLocalDirectory();
		}];

	UIAlertAction* openSafari = [UIAlertAction actionWithTitle:@"Open in Safari" 
		style:UIAlertActionStyleDefault 
		handler:^(UIAlertAction * action) {
			//Open in safari options
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", ImageURL]]];
		}];

	UIAlertAction* noButton = [UIAlertAction actionWithTitle:@"No" 
		style:UIAlertActionStyleDefault 
		handler:^(UIAlertAction * action) {
			[alert dismissViewControllerAnimated:YES completion:nil];
		}];

	[alert addAction:yesButton];
	[alert addAction:openSafari];
	[alert addAction:noButton];
	
	[controller presentViewController:alert animated:YES completion:nil];
}
%end