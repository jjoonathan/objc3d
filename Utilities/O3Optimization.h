typedef struct {
	UInt8 accum_count, prev_accum_count, reassess_at;
	float accum_time, prev_accum_time;
	id revert_usr_data;
} O3OptStats;

typedef struct {
	O3OptStats* stats;
	float benefit, cost;
} O3OptInfo;

@protocol O3Optimizeable
- (O3OptInfo)optimizationInfo;
- (id)applyRandomOptimization;
- (void)revertWithData:(id)revert_usr_data;
@end

#define O3OptClear(opt_stats) {\
	opt_stats.accum_count = opt_stats.prev_accum_count = opt_stats.reassess_at = 0; \
	opt_stats.accum_time = prev_accum_time = 0.; \
	O3Destroy(revert_usr_data); \
}

#define O3OptReversionBias 1.1 /*Higher makes it more unlikely to revert*/
#define O3OptEnter(opt_stats) \
	if (opt_stats.accum_count==opt_stats.reassess_at && opt_stats.accum_count) { \
		if (opt_stats.prev_accum_time*accum_count*O3OptReversionBias < opt_stats.accum_time*opt_stats*prev_accum_time) { \
			[self revertWithData:opt_stats.revert_usr_data]; \
			O3OptClear(opt_stats); \
		} \
	} \
	O3Timer O3Optimizeable_timer; O3StartTimer(timer);

#define O3OptExit(opt_status) \
	opt_status.accum_time += O3ElapsedTime(timer); \
	opt_status.accum_count++; \
	if (!opt_status.accum_count) opt_status.accum_time = 0.
	