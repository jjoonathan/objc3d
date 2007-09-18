/**
 *  @file O3ArchiveStatisticsGatherer.h
 *  @license MIT License (see LICENSE.txt)
 *  @date 7/19/07.
 *  @author Jonathan deWerd
 *  @copyright Copyright (c) 2007 Jonathan deWerd. All rights reserved, except those explicitly granted by the MIT license in LICENSE.txt.
 */
#import <map>
@class O3ArchiveStatistic;

@interface O3ArchiveStatisticsGatherer : NSCoder {
	NSMutableDictionary* mKT;
	NSMutableDictionary* mST;
	NSMutableDictionary* mCT;
	NSDictionary* mClassNameMappings;
}
+ (void)gatherStatisticsForRootObject:(id)obj KT:(NSArray**)kt ST:(NSArray**)st CT:(NSArray**)ct;
+ (void)gatherStatisticsForRootObject:(id)obj key:(NSString*)k KT:(NSArray**)kt ST:(NSArray**)st CT:(NSArray**)ct classNameMap:(NSDictionary*)cmap;
- (void)gatherStatisticsIntoKT:(NSArray**)kt ST:(NSArray**)st CT:(NSArray**)ct;
NSDictionary* O3ArchiveStringMapFromArray(NSArray* a);
@end

@interface O3ArchiveStatistic : NSObject {
	NSString* key;
	UIntP numOccurances;
	IntP winnage; //[key length]*numOccurances-O3BytesRequiredForCInt([m[KSC]T count])
}
@end

@interface NSCoder (O3StatisticGatherer)
- (BOOL)isStatisticGatherer; ///If this returns YES you can submit dummy objects for archiving.
@end
