/**
 *  @file O3Space.mm
 *  @license MIT License (see LICENSE.txt)
 *  @date 4/12/08.
 *  @author Jonathan deWerd
 *  @copyright Copyright 2008 Jonathan deWerd. This file is distributed under the MIT license (see accompanying file for details).
 */
#import "O3Space.h"

@implementation O3Space
/************************************/ #pragma mark Init & Destruction /************************************/
- (id)initWithCoder:(NSCoder*)coder {
	O3SuperInitOrDie();
	return self;
}

- (void)encodeWithCoder:(NSCoder*)coder {
}

/************************************/ #pragma mark Super /************************************/
- (O3Space*)superspace {
	return mSuperspace;
}

- (void)setSuperspaceWithoutAdjusting:(O3Space*)ss {
	mSuperspace = ss;
}

- (void)setSuperspace:(O3Space*)ss {
	O3Mat4x4d trans = O3SpaceMatrixFromTo(mSuperspace, ss);
	O3Mat4x4d newSpace = [self matrixToSuper]*trans;
	[self setMatrixToSuper:newSpace];
}

- (O3Space*)space {
	return self;
}


/************************************/ #pragma mark GL /************************************/
- (void)push:(O3RenderContext*)ctx {
	glPushMatrix();
	glMultMatrixd([self matrixToSuper].GLMatrix());
}

- (void)pop:(O3RenderContext*)ctx {
	glPopMatrix();
}


/************************************/ #pragma mark Matrix interface /************************************/
- (void)clear {
	[self setMatrixToRoot:O3Mat4x4d::GetIdentity()];
}

- (void)setMatrixToRoot:(O3Mat4x4d)mat {
	//Set to be (me * super0 * super1 * super2 ... root) = mat
	
	//Build a list of spaces to the root (super0, super1, super2, ... root)
	O3Space* space = self;
	std::vector<O3Space*> to_stack;
	while (space) {
		to_stack.push_back(space);
		space = [space superspace];
	}
	
	//And undo each's transformation: (me * super0 * super1 * super2 ... root) * (root ... super2' * super1' * super0') = me
	std::vector<O3Space*>::reverse_iterator it=to_stack.rbegin(), e=to_stack.rend();
	for (; it!=e; it++) {
		space = *it;
		mat *= [space matrixFromSuper];
	}
	
	[self setMatrixToSuper:mat];
}

- (void)setMatrixToSuper:(O3Mat4x4d)mat {
	[self doesNotRecognizeSelector:_cmd];
}

- (O3Mat4x4d)matrixToSuper {
	[self doesNotRecognizeSelector:_cmd];
	return O3Mat4x4d();
}

- (O3Mat4x4d)matrixFromSuper {
	O3Optimizable();
	O3Mat4x4d ret = [self matrixToSuper];
	return ret.Invert3x4();
}

- (void)applyTransformation:(O3Mat4x4d)trans inSpace:(O3Space*)sp {
	O3Mat4x4d mts = [self matrixToSuper];
	O3Mat4x4d povchanger = O3SpaceMatrixFromTo(sp, [self superspace]);
	trans *= povchanger;
	[self setMatrixToSuper:mts*trans];
}

- (void)setTransformation:(O3Mat4x4d)trans inSpace:(O3Space*)sp {
	O3Mat4x4d povchanger = O3SpaceMatrixFromTo(sp, [self superspace]);
	trans *= povchanger;
	[self setMatrixToSuper:trans];
}




/************************************/ #pragma mark Moving from space to space /************************************/
O3EXTERN_C O3Mat4x4d O3SpaceMatrixFromTo(O3Space* fromspace, O3Space* tospace) {
	if (fromspace==tospace) return O3Mat4x4d::GetIdentity();
	O3Mat4x4d mat = [fromspace matrixToSuper];
	O3Space* current_space = fromspace->mSuperspace;
	while (current_space) {
		mat *= [current_space matrixToSuper];
		current_space = [current_space superspace];
		if (current_space==tospace) return mat;
	}
	
	//Build a list of spaces to transform into from root
	std::vector<O3Space*> to_stack;
	O3Space* ts = tospace;
	while (ts) {
		to_stack.push_back(ts);
		ts = [tospace superspace];
	}
	
	//And apply them in reverse order
	std::vector<O3Space*>::reverse_iterator it=to_stack.rbegin(), e=to_stack.rend();
	for (; it!=e; it++) {
		current_space = *it;
		mat *= [current_space matrixFromSuper];
		if (current_space==tospace) return mat;
	}
	return mat;
}

- (O3Mat4x4d)matrixToSpace:(O3Space*)tospace {
	return O3SpaceMatrixFromTo(self, tospace);
}

- (O3Mat4x4d)matrixFromSpace:(O3Space*)fromspace {
	return O3SpaceMatrixFromTo(fromspace, self);
}


/************************************/ #pragma mark Debugging /************************************/
- (double)drift {
	O3Mat4x4d ident = O3Mat4x4d::GetIdentity();
	O3Mat4x4d id_mat = [self matrixFromSuper]*[self matrixToSuper];
	id_mat = id_mat-ident;
	double accum_drift = 0;
	for (UIntP i=0; i<16; i++) 
		accum_drift+=O3Abs(id_mat(i));
	return accum_drift;
}


@end
