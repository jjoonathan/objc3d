//
//  O3TestTet.mm
//  ObjC3D
//
//  Created by Jonathan deWerd on 12/25/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//
#import "O3TestTet.h"

float O3TestTetVerts[3*4] = {0,0,0,
                            1,0,0,
                            0,1,0,
                            0,0,1};
UInt8 O3TestTetColors[4*4] = {.5,.5,.5,1,
                              1,0,0,1,
                              0,1,0,1,
                              0,0,1,1};
UInt8 O3TestTetIndicies[3*4] = {1,2,3,
                                0,1,2,
                                1,0,3,
                                2,0,3};
							
                            

@implementation O3TestTet

- (void)renderWithContext:(O3RenderContext*)ctx {
	glEnableClientState(GL_COLOR_ARRAY);
	glEnableClientState(GL_VERTEX_ARRAY);
	glColorPointer(4, GL_FLOAT, 4*sizeof(float), O3TestTetColors);
	glVertexPointer(3, GL_FLOAT, 3*sizeof(float), O3TestTetVerts);
	glDrawElements(GL_TRIANGLES, 4, GL_UNSIGNED_BYTE, (GLvoid*)O3TestTetIndicies);
	glDisableClientState(GL_COLOR_ARRAY);
	glDisableClientState(GL_VERTEX_ARRAY);
}

- (void)tickWithContext:(O3RenderContext*)context {
}

@end
