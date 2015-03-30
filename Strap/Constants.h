#ifdef DEBUG
#	define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#	define DLog(...)
#endif

#define KVNRGBColor(r, g, b)		[UIColor colorWithRed:(float)r/255.0 green:(float)g/255.0 blue:(float)b/255.0 alpha:1.0]
// notice the alpha value is still a float 0.0-1.0 instead of 0-255
#define KVNRGBAColor(r, g, b, a)	[UIColor colorWithRed:(float)r/255.0 green:(float)g/255.0 blue:(float)b/255.0 alpha:a]

#define KVNFontRegular(ps)			[UIFont fontWithName:@"HelveticaNeue" size:ps]
