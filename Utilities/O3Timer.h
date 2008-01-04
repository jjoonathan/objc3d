//
//  O3Timer.h
//  ObjC3D
//
//  Created by Jonathan deWerd on 12/27/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//
#import <Cocoa/Cocoa.h>
#import <mach/mach_time.h>

/** \group O3Timer
 * O3Timer can be used for simple, fast timing. 
 * The lifecycle should look like:
 * O3Timer t;
 * //Repeat
 * O3StartTimer(t);
 * ...
 * printf("Time: %f", O3ElapsedTime(t));
 * //End Repeat
 */

#ifdef O3AllowMachCalls


typedef uint64_t O3Timer;
static inline double O3TimerRawToSecondsMultiplier() {
	static double mult = 0;
	if (mult==0) {
		mach_timebase_info_data_t info;
		mach_timebase_info(&info);
		mult = 1e-9 * (double)info.numer / (double)info.denom;
	}
	return mult;
}

#define O3StartTimer(timer) (timer = mach_absolute_time())
#define O3RawElapsedTime(timer) (mach_absolute_time() - timer)
#define O3ElapsedTime(timer) (O3TimerRawToSecondsMultiplier()*O3RawElapsedTime(timer))


#else /*!O3AllowMachCalls*/


typedef NSTimeInterval O3Timer;
#define O3StartTimer(timer) timer = [NSDate timeIntervalSinceReferenceDate]
#define O3ElapsedTime(timer) ([NSDate timeIntervalSinceReferenceDate] - timer)
#define O3RawElapsedTime(timer) ([NSDate timeIntervalSinceReferenceDate] - timer)


#endif

