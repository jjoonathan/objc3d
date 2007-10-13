///This file works around a bug (?) in IB in 9A599 which makes KVC not work. For some reason this fixes it.

- (id)valueForKey:(NSString*)k {
	return [super valueForKey:k];
}

- (id)valueForKeyPath:(NSString*)k {
	return [super valueForKeyPath:k];
}

- (void)setValue:(id)v forKey:(NSString*)k {
	[super setValue:v forKey:k];
}

- (void)setValue:(id)v forKeyPath:(NSString*)k {
	[super setValue:v forKeyPath:k];
}