/**
 *  @file O3TestArchivers.mm
 *  @license MIT License (see LICENSE.txt)
 *  @date 4/15/07.
 *  @author Jonathan deWerd
 *  @copyright Copyright 2007 Jonathan deWerd. This file is distributed under the MIT license (see accompanying file for details).
 */
#import "O3TestArchivers.h"
#import "O3BufferedWriter.h"
#import "O3BufferedReader.h"
#import "O3EncodingInterpretation.h"
#import "O3NonlinearWriter.h"
#import "O3Value.h"
#import "O3KeyedArchiver.h"
#import "O3KeyedUnarchiver.h"
#import "O3Camera.h"
using namespace ObjC3D;

#define TCLog(str, args...) printf([[NSString stringWithFormat:str @"\n",##args] UTF8String])

@implementation O3TestArchivers

- (void)testUnsignedIntReadWrite {
	TCLog(@"Test case '-[%@ %@]' beginning.", [self className], NSStringFromSelector(_cmd));
	NSString* tmp_path = @"/tmp/O3ArchiveTest.o3a";
	[[NSFileManager defaultManager] createFileAtPath:tmp_path contents:nil attributes:nil];
	NSFileHandle* handle = [NSFileHandle fileHandleForWritingAtPath:tmp_path];
	O3BufferedWriter bhw(handle);
	bhw.WriteUIntAsBytes(0xCAFEBABE,4);
	bhw.WriteUIntAsBytes(0xFF,1);
	STAssertThrows(bhw.WriteUIntAsBytes(0x100,1), @"It should fail an assertion if a 2 byte value is requested to be squeezed into one byte.");
	bhw.WriteUIntAsBytes(0xCAFEBABE,6);
	bhw.WriteUIntAsBytes(0xFF,1);
	STAssertThrows(bhw.WriteUIntAsBytes(0x100,1), @"It should fail an assertion if a 2 byte value is requested to be squeezed into one byte.");
	bhw.WriteUIntAsBytes(0xCAFEBABEDEADBEEFull,8);
	bhw.WriteUIntAsBytes(0xCAFEBABE,4);
	bhw.WriteUIntAsBytes(0xCAFEBABE,10);
	STAssertThrows(bhw.WriteUIntAsBytes(0xCAFEBABE,3), @"It should fail an assertion if a 4 byte value is requested to be squeezed into three bytes.");
	STAssertThrows(bhw.WriteUIntAsBytes(0xCAFEBABEDEADBEEFull,7), @"It should fail an assertion if a 8 byte value is requested to be squeezed into seven bytes.");
	bhw.Close();
	
	NSFileHandle* h = [NSFileHandle fileHandleForReadingAtPath:tmp_path];
	O3BufferedReader bhr(h);
	STAssertTrue(bhr.ReadBytesAsUInt32(4)==0xCAFEBABE, @"Write/readback discrepancy!");
	STAssertTrue(bhr.ReadBytesAsUInt64(1)==0xFFull, @"Write/readback discrepancy!");
	STAssertTrue(bhr.ReadBytesAsUInt32(6)==0xCAFEBABE, @"Write/readback discrepancy!");
	STAssertTrue(bhr.ReadBytesAsUInt32(1)==0xFF, @"Write/readback discrepancy!");
	STAssertTrue(bhr.ReadBytesAsUInt64(8)==0xCAFEBABEDEADBEEFull, @"Write/readback discrepancy!");
	STAssertTrue(bhr.ReadBytesAsUInt64(4)==0xCAFEBABEull, @"Write/readback discrepancy!");
	STAssertTrue(bhr.ReadBytesAsUInt64(10)==0xCAFEBABEull, @"Write/readback discrepancy!");
	bhr.Close();

	[[NSFileManager defaultManager] removeFileAtPath:tmp_path handler:nil];
}

- (void)testSignedIntReadWrite {
	TCLog(@"Test case '-[%@ %@]' beginning.", [self className], NSStringFromSelector(_cmd));
	NSString* tmp_path = @"/tmp/O3ArchiveTest.o3a";
	[[NSFileManager defaultManager] createFileAtPath:tmp_path contents:nil attributes:nil];
	NSFileHandle* handle = [NSFileHandle fileHandleForWritingAtPath:tmp_path];
	O3BufferedWriter bhw(handle);
	bhw.WriteIntAsBytes(0xAFEBABE,4);
	bhw.WriteIntAsBytes(- 0xAFEBABE,4);
	bhw.WriteIntAsBytes(-127,1);
	STAssertThrows(bhw.WriteIntAsBytes(0x80,1), @"It should fail an assertion if a 2 byte value is requested to be squeezed into one byte.");
	bhw.WriteIntAsBytes(- 0xAFEBABE,6);
	bhw.WriteIntAsBytes(- 0xFF,2);
	STAssertThrows(bhw.WriteIntAsBytes(- 0x81,1), @"It should fail an assertion if a 2 byte value is requested to be squeezed into one byte.");
	bhw.WriteIntAsBytes(0xAFEBABEDEADBEEFll,8);
	bhw.WriteIntAsBytes(- 0xAFEBABEDEADBEEFll,8);
	bhw.WriteIntAsBytes(0xAFEBABE,4);
	bhw.WriteIntAsBytes(- 0xCAFEBABEll,10);
	STAssertThrows(bhw.WriteIntAsBytes(0xCAFEBABE,3), @"It should fail an assertion if a 4 byte value is requested to be squeezed into three bytes.");
	STAssertThrows(bhw.WriteIntAsBytes(0xCAFEBABEDEADBEEFll,7), @"It should fail an assertion if a 8 byte value is requested to be squeezed into seven bytes.");
	bhw.Close();
	
	NSFileHandle* h2 = [NSFileHandle fileHandleForReadingAtPath:tmp_path];
	O3BufferedReader bhr(h2);
	Int32 rval32;
	Int64 rval64;
	rval32=bhr.ReadBytesAsInt32(4);
		STAssertTrue(rval32==0xAFEBABE, @"Write/readback discrepancy! rval==0x%X",rval32);
	rval32=bhr.ReadBytesAsInt32(4);
		STAssertTrue(rval32==- 0xAFEBABE, @"Write/readback discrepancy! rval==0x%X",rval32);
	rval64=bhr.ReadBytesAsInt64(1);
		STAssertTrue(rval64==-127, @"Write/readback discrepancy! rval==0x%qX",rval64);
	rval32=bhr.ReadBytesAsInt32(6);
		STAssertTrue(rval32==-0xAFEBABE, @"Write/readback discrepancy! rval==0x%X",rval32);
	rval32=bhr.ReadBytesAsInt32(2);
		STAssertTrue(rval32==-0xFF, @"Write/readback discrepancy! rval==0x%X",rval32);
	rval64=bhr.ReadBytesAsInt64(8);
		STAssertTrue(rval64==0xAFEBABEDEADBEEFll, @"Write/readback discrepancy! rval==0x%qX",rval64);
	rval64=bhr.ReadBytesAsInt64(8);
		STAssertTrue(rval64==-0xAFEBABEDEADBEEFll, @"Write/readback discrepancy! rval==0x%qX",rval64);
	rval64=bhr.ReadBytesAsInt64(4);
		STAssertTrue(rval64==0xAFEBABE, @"Write/readback discrepancy! rval==0x%qX",rval64);
	rval64=bhr.ReadBytesAsInt64(10);
		STAssertTrue(rval64==-0xCAFEBABEll, @"Write/readback discrepancy! rval==0x%qX",rval64);
	bhr.Close();
	
	[[NSFileManager defaultManager] removeFileAtPath:tmp_path handler:nil];
}

- (void)testCIntReadWrite {
	TCLog(@"Test case '-[%@ %@]' beginning.", [self className], NSStringFromSelector(_cmd));
	NSString* tmp_path = @"/tmp/O3ArchiveTest.o3a";
	[[NSFileManager defaultManager] createFileAtPath:tmp_path contents:nil attributes:nil];
	NSFileHandle* handle = [NSFileHandle fileHandleForWritingAtPath:tmp_path];
	O3BufferedWriter bhw(handle);
	bhw.WriteCInt(0xAFEBABE);
	bhw.WriteCInt(- 0xAFEBABE);
	bhw.WriteCInt(-127);
	bhw.WriteCInt(- 0xAFEBABE);
	bhw.WriteCInt(- 0xFF);
	bhw.WriteCInt(0xAFEBABEDEADBEEFll);
	bhw.WriteCInt(- 0xAFEBABEDEADBEEFll);
	bhw.WriteCInt(0xAFEBABE);
	bhw.WriteCInt(- 0xCAFEBABEll);
	bhw.WriteCInt(0);
	bhw.Close();
	
	NSFileHandle* h2 = [NSFileHandle fileHandleForReadingAtPath:tmp_path];
	O3BufferedReader bhr(h2);
	Int32 rval32;
	Int64 rval64;
	rval32=bhr.ReadCIntAsInt32();
	STAssertTrue(rval32==0xAFEBABE, @"Write/readback discrepancy! rval==0x%X",rval32);
	rval32=bhr.ReadCIntAsInt32();
	STAssertTrue(rval32==- 0xAFEBABE, @"Write/readback discrepancy! rval==0x%X",rval32);
	rval64=bhr.ReadCIntAsInt64();
	STAssertTrue(rval64==-127, @"Write/readback discrepancy! rval==0x%qX",rval64);
	rval32=bhr.ReadCIntAsInt32();
	STAssertTrue(rval32==-0xAFEBABE, @"Write/readback discrepancy! rval==0x%X",rval32);
	rval32=bhr.ReadCIntAsInt32();
	STAssertTrue(rval32==-0xFF, @"Write/readback discrepancy! rval==0x%X",rval32);
	rval64=bhr.ReadCIntAsInt64();
	STAssertTrue(rval64==0xAFEBABEDEADBEEFll, @"Write/readback discrepancy! rval==0x%qX",rval64);
	rval64=bhr.ReadCIntAsInt64();
	STAssertTrue(rval64==-0xAFEBABEDEADBEEFll, @"Write/readback discrepancy! rval==0x%qX",rval64);
	rval64=bhr.ReadCIntAsInt64();
	STAssertTrue(rval64==0xAFEBABE, @"Write/readback discrepancy! rval==0x%qX",rval64);
	rval64=bhr.ReadCIntAsInt64();
	STAssertTrue(rval64==-0xCAFEBABEll, @"Write/readback discrepancy! rval==0x%qX",rval64);
	rval64=bhr.ReadCIntAsInt64();
	STAssertTrue(rval64==0, @"Write/readback discrepancy! rval==0x%qX",rval64);
	bhr.Close();
	
	[[NSFileManager defaultManager] removeFileAtPath:tmp_path handler:nil];
}

- (void)testUCIntReadWrite {
	TCLog(@"Test case '-[%@ %@]' beginning.", [self className], NSStringFromSelector(_cmd));
	NSString* tmp_path = @"/tmp/O3ArchiveTest.o3a";
	[[NSFileManager defaultManager] createFileAtPath:tmp_path contents:nil attributes:nil];
	NSFileHandle* handle = [NSFileHandle fileHandleForWritingAtPath:tmp_path];
	O3BufferedWriter bhw(handle);
	bhw.WriteUCInt(0xCAFEBABE);
	bhw.WriteUCInt(0xCAFEBABE);
	bhw.WriteUCInt(127);
	bhw.WriteUCInt(0xCAFEBABE);
	bhw.WriteUCInt(0xFF);
	bhw.WriteUCInt(0xCAFEBABEDEADBEEFll);
	bhw.WriteUCInt(0xCAFEBABEDEADBEEFll);
	bhw.WriteUCInt(0xCAFEBABE);
	bhw.WriteUCInt(0xCAFEBABEll);
	bhw.WriteUCInt(0);
	bhw.Close();
	
	NSFileHandle* h2 = [NSFileHandle fileHandleForReadingAtPath:tmp_path];
	O3BufferedReader bhr(h2);
	UInt32 rval32;
	UInt64 rval64;
	rval32=bhr.ReadUCIntAsUInt32();
	STAssertTrue(rval32==0xCAFEBABE, @"Write/readback discrepancy! rval==0x%X",rval32);
	rval32=bhr.ReadUCIntAsUInt32();
	STAssertTrue(rval32==0xCAFEBABE, @"Write/readback discrepancy! rval==0x%X",rval32);
	rval64=bhr.ReadUCIntAsUInt64();
	STAssertTrue(rval64==127, @"Write/readback discrepancy! rval==0x%qX",rval64);
	rval32=bhr.ReadUCIntAsUInt32();
	STAssertTrue(rval32==0xCAFEBABE, @"Write/readback discrepancy! rval==0x%X",rval32);
	rval32=bhr.ReadUCIntAsUInt32();
	STAssertTrue(rval32==0xFF, @"Write/readback discrepancy! rval==0x%X",rval32);
	rval64=bhr.ReadUCIntAsUInt64();
	STAssertTrue(rval64==0xCAFEBABEDEADBEEFll, @"Write/readback discrepancy! rval==0x%qX",rval64);
	rval64=bhr.ReadUCIntAsUInt64();
	STAssertTrue(rval64==0xCAFEBABEDEADBEEFll, @"Write/readback discrepancy! rval==0x%qX",rval64);
	rval64=bhr.ReadUCIntAsUInt64();
	STAssertTrue(rval64==0xCAFEBABE, @"Write/readback discrepancy! rval==0x%qX",rval64);
	rval64=bhr.ReadUCIntAsUInt64();
	STAssertTrue(rval64==0xCAFEBABEll, @"Write/readback discrepancy! rval==0x%qX",rval64);
	rval64=bhr.ReadUCIntAsUInt64();
	STAssertTrue(rval64==0, @"Write/readback discrepancy! rval==0x%qX",rval64);
	bhr.Close();
	
	[[NSFileManager defaultManager] removeFileAtPath:tmp_path handler:nil];
}

- (void)testFloatReadWrite {
	TCLog(@"Test case '-[%@ %@]' beginning.", [self className], NSStringFromSelector(_cmd));
	NSString* tmp_path = @"/tmp/O3ArchiveTest.o3a";
	[[NSFileManager defaultManager] createFileAtPath:tmp_path contents:nil attributes:nil];
	NSFileHandle* handle = [NSFileHandle fileHandleForWritingAtPath:tmp_path];
	O3BufferedWriter bhw(handle);
	bhw.WriteFloat(1.337);
	bhw.WriteFloat(0);
	bhw.WriteFloat(10000.5);
	bhw.WriteFloat(-123.4);
	bhw.WriteFloat(-.0000000001);
	bhw.WriteDouble(1.0e150);
	bhw.WriteDouble(-1.0e150);
	bhw.WriteDouble(0);
	bhw.WriteDouble(-123.4);
	bhw.Close();
	
	NSFileHandle* h3 = [NSFileHandle fileHandleForReadingAtPath:tmp_path];
	O3BufferedReader bhr(h3);
	STAssertTrue(bhr.ReadFloat()==1.337f, @"Readback of float failed.");
	STAssertTrue(bhr.ReadFloat()==0.f, @"Readback of float failed.");
	STAssertTrue(bhr.ReadFloat()==10000.5f, @"Readback of float failed.");
	STAssertTrue(bhr.ReadFloat()==-123.4f, @"Readback of float failed.");
	STAssertTrue(bhr.ReadFloat()==-.0000000001f, @"Readback of float failed.");
	STAssertTrue(bhr.ReadDouble()==1.0e150, @"Readback of double failed.");
	STAssertTrue(bhr.ReadDouble()==-1.0e150, @"Readback of double failed.");
	STAssertTrue(bhr.ReadDouble()==0, @"Readback of double failed.");
	STAssertTrue(bhr.ReadDouble()==-123.4, @"Readback of double failed.");
	bhr.Close();
	
	[[NSFileManager defaultManager] removeFileAtPath:tmp_path handler:nil];
}

- (void)testNonlinearWriter {
	TCLog(@"Test case '-[%@ %@]' beginning.", [self className], NSStringFromSelector(_cmd));
	NSString* tmp_path = @"/tmp/O3NonlinearWriterTest.o3a";
	O3NonlinearWriter w;
	UIntP p0 = w.ReservePlaceholder();//
	UIntP p1 = w.ReservePlaceholder();//
	UIntP p2 = w.ReservePlaceholder();//
	UIntP p3 = w.ReservePlaceholder();//
	UIntP p4 = w.ReservePlaceholder();//
	UIntP p5 = w.ReservePlaceholder();//
	UIntP p6 = w.ReservePlaceholder();//
	UIntP p7 = w.ReservePlaceholder(); p7;
	UIntP p8 = w.ReservePlaceholder();//
	UIntP p9 = w.ReservePlaceholder();//
	w.WriteByteAtPlaceholder(0x01,p6);
	w.WriteBytesAtPlaceholder("abc",3,p2);
	w.WriteCCStringAtPlaceholder("forty-two!",p9);
	w.WriteCIntAtPlaceholder(12345,p4);
	w.WriteDataAtPlaceholder([NSData dataWithBytes:"And the answer is..." length:20], p8);
	w.WriteDoubleAtPlaceholder(1.337, p0);
	w.WriteFloatAtPlaceholder(6.9, p1);
	w.WriteIntAsBytesAtPlaceholder(123456789, 6, p3);
	w.WriteUCIntAtPlaceholder(987987432, p5);
	int d = open([tmp_path UTF8String], O_WRONLY | O_TRUNC | O_CREAT, 0777);
	w.WriteToFileDescriptor(d);
	close(d);
	
	NSFileHandle* h = [NSFileHandle fileHandleForReadingAtPath:tmp_path];
	O3BufferedReader bhr(h);
	STAssertTrue(bhr.ReadDouble()==1.337, @"Readback of double failed.");
	STAssertTrue(bhr.ReadFloat()==6.9f, @"Readback of float failed.");
	STAssertTrue(bhr.ReadByte()=='a'&&bhr.ReadByte()=='b'&&bhr.ReadByte()=='c', @"Readback of bytes failed.");
	STAssertTrue(bhr.ReadBytesAsInt32(6)==123456789, @"Readback of CInt failed.");
	STAssertTrue(bhr.ReadCIntAsInt32()==12345, @"Readback of CInt failed.");
	STAssertTrue(bhr.ReadUCIntAsUInt32()==987987432, @"Readback of UCInt failed.");
	STAssertTrue(bhr.ReadByte()==0x1, @"Readback of byte failed.");
	[[NSData dataWithBytes:"And the answer is..." length:20] isEqualToData:bhr.ReadData(20)];
	STAssertTrue(!strcmp([bhr.ReadCCString() UTF8String],"forty-two!"), @"Readback of CCString failed.");
	bhr.Close();
	
	[[NSFileManager defaultManager] removeFileAtPath:tmp_path handler:nil];	
}

- (void)testEncodingSerializer {
	TCLog(@"Test case '-[%@ %@]' beginning.", [self className], NSStringFromSelector(_cmd));
	int trash = 2397856;
	typedef struct {
		char a;
		int a0;
		short b;
		long c;
		long long d;
		unsigned char e;
		unsigned int f;
		unsigned short g;
		unsigned long h;
		unsigned long long i;
		float j;
		double k;
		void* dat;
		NSString* str;
		const char* l;
		SEL m;
		Class n;
		int o[5];
		char p;
	} tst_struct_t;
	tst_struct_t t1 = {-1,-2,-3,-4,-5,6,7,8,9,10,11.f,12.,&trash,[NSString stringWithFormat:@"%i check",trash],"Good String!", @selector(alloc), [NSObject class], {0,1,2,3,4}, -8};
	NSMutableData* dat = O3SerializeDataOfType(&t1, @encode(tst_struct_t));
	tst_struct_t t2 = {18,18,18,18,18,18,18,18,18,18,18.f,18.,&trash,[NSString stringWithFormat:@"%i check",trash],"Bad String!", @selector(init), [NSString class], {18,18,18,18,18}, -18};
	t2.str = [NSString stringWithFormat:@"%i",trash];
	t2.dat = &trash;
	O3DeserializeDataOfType(&t2, @encode(tst_struct_t), dat);
	#define O3TestArchiversSerialization(v) STAssertTrue(t1.v==t2.v, @"Mismatch in token \"" #v @"\"!")
	O3TestArchiversSerialization(a);
	O3TestArchiversSerialization(a0);
	O3TestArchiversSerialization(b);
	O3TestArchiversSerialization(c);
	O3TestArchiversSerialization(d);
	O3TestArchiversSerialization(e);
	O3TestArchiversSerialization(f);
	O3TestArchiversSerialization(g);
	O3TestArchiversSerialization(h);
	O3TestArchiversSerialization(i);
	O3TestArchiversSerialization(j);
	O3TestArchiversSerialization(k);
	STAssertFalse(strcmp(t1.l, t2.l), @"Strings \"%s\" and \"%s\" should be equal, but aren't.", t1.l, t2.l);
	STAssertTrue(!t2.dat, @"void* should not be encoded and should be decoded as NULL.");
	STAssertTrue(!t2.str, @"Objective C objects should not be encoded and should be decoded as NULL.");
	O3TestArchiversSerialization(m);
	O3TestArchiversSerialization(n);
	STAssertTrue(t1.o[0]==t2.o[0], @"Struct.array members should be equal, but aren't. (%i!=%i)",t1.o[0],t2.o[0]);
	STAssertTrue(t1.o[1]==t2.o[1], @"Struct.array members should be equal, but aren't. (%i!=%i)",t1.o[1],t2.o[1]);
	STAssertTrue(t1.o[2]==t2.o[2], @"Struct.array members should be equal, but aren't. (%i!=%i)",t1.o[2],t2.o[2]);
	STAssertTrue(t1.o[3]==t2.o[3], @"Struct.array members should be equal, but aren't. (%i!=%i)",t1.o[3],t2.o[3]);
	STAssertTrue(t1.o[4]==t2.o[4], @"Struct.array members should be equal, but aren't. (%i!=%i)",t1.o[4],t2.o[4]);
	O3TestArchiversSerialization(p);
}

- (void)testTypedObjectWrite {
	TCLog(@"Test case '-[%@ %@]' beginning.", [self className], NSStringFromSelector(_cmd));
	O3NonlinearWriter w;
	w.WriteTypedObjectHeaderAtPlaceholder(nil, 16, O3PkgTypeDictionary, w.ReservePlaceholder());
	w.WriteTypedObjectHeaderAtPlaceholder(nil, 4, O3PkgTypeDictionary, w.ReservePlaceholder());
	w.WriteTypedObjectHeaderAtPlaceholder(nil, 238974789, O3PkgTypeDictionary, w.ReservePlaceholder());
	w.WriteTypedObjectHeaderAtPlaceholder(@"SomePkg", 238974789, O3PkgTypeObject, w.ReservePlaceholder());
	w.WriteTypedObjectHeaderAtPlaceholder(@"", 0, O3PkgTypeObject, w.ReservePlaceholder());
	STAssertThrows(w.WriteTypedObjectHeaderAtPlaceholder(@"", 0, O3PkgTypeDictionary, w.ReservePlaceholder()), @"Should not be able to write a O3PkgTypeDictionary with a name");
	STAssertThrows(w.WriteTypedObjectHeaderAtPlaceholder(nil, 0, O3PkgTypeObject, w.ReservePlaceholder()), @"Should not be able to write a O3PkgTypeObject without a name");
	NSData* dat = w.Data();
	O3NonlinearWriter x;
	x.WriteByteAtPlaceholder(0x8C,x.ReservePlaceholder());
	x.WriteByteAtPlaceholder(0x84,x.ReservePlaceholder());
	x.WriteByteAtPlaceholder(0x8F,x.ReservePlaceholder()); x.WriteUCIntAtPlaceholder(238974789, x.ReservePlaceholder());
	x.WriteByteAtPlaceholder(0xEF,x.ReservePlaceholder()); x.WriteCCStringAtPlaceholder("SomePkg", x.ReservePlaceholder()); x.WriteUCIntAtPlaceholder(238974789, x.ReservePlaceholder());
	x.WriteByteAtPlaceholder(0xE0,x.ReservePlaceholder()); x.WriteCCStringAtPlaceholder("", x.ReservePlaceholder());
	NSData* dat2 = x.Data();
	STAssertTrue([dat isEqualToData:dat2], @"Somehow the nonlinear writer is not writing key+object headers to specification. %@ != %@", dat, dat2);
}

- (void)testKVHeaderWrite {
	TCLog(@"Test case '-[%@ %@]' beginning.", [self className], NSStringFromSelector(_cmd));
	O3NonlinearWriter w;
	w.WriteKVHeaderAtPlaceholder(@"keya", nil, 16, O3PkgTypeDictionary, w.ReservePlaceholder());
	w.WriteKVHeaderAtPlaceholder(@"keyb", nil, 4, O3PkgTypeDictionary, w.ReservePlaceholder());
	w.WriteKVHeaderAtPlaceholder(@"keyc", nil, 238974789, O3PkgTypeDictionary, w.ReservePlaceholder());
	w.WriteKVHeaderAtPlaceholder(@"1", @"SomePkg", 238974789, O3PkgTypeObject, w.ReservePlaceholder());
	w.WriteKVHeaderAtPlaceholder(@"2", @"", 0, O3PkgTypeObject, w.ReservePlaceholder());
	STAssertThrows(w.WriteKVHeaderAtPlaceholder(@"",@"", 0, O3PkgTypeDictionary, w.ReservePlaceholder()), @"Should not be able to write a O3PkgTypeDictionary with a name");
	STAssertThrows(w.WriteKVHeaderAtPlaceholder(@"",nil, 0, O3PkgTypeObject, w.ReservePlaceholder()), @"Should not be able to write a O3PkgTypeObject without a name");
	NSData* dat = w.Data();
	O3NonlinearWriter x;
	x.WriteCCStringAtPlaceholder(@"keya", x.ReservePlaceholder(), O3CCSKeyTable); x.WriteByteAtPlaceholder(0x8C,x.ReservePlaceholder());
	x.WriteCCStringAtPlaceholder(@"keyb", x.ReservePlaceholder(), O3CCSKeyTable); x.WriteByteAtPlaceholder(0x84,x.ReservePlaceholder());
	x.WriteCCStringAtPlaceholder(@"keyc", x.ReservePlaceholder(), O3CCSKeyTable); x.WriteByteAtPlaceholder(0x8F,x.ReservePlaceholder()); x.WriteUCIntAtPlaceholder(238974789, x.ReservePlaceholder());
	x.WriteCCStringAtPlaceholder(@"1", x.ReservePlaceholder(), O3CCSKeyTable);    x.WriteByteAtPlaceholder(0xEF,x.ReservePlaceholder()); x.WriteCCStringAtPlaceholder(@"SomePkg", x.ReservePlaceholder(), O3CCSClassTable); x.WriteUCIntAtPlaceholder(238974789, x.ReservePlaceholder());
	x.WriteCCStringAtPlaceholder(@"2", x.ReservePlaceholder(), O3CCSKeyTable);    x.WriteByteAtPlaceholder(0xE0,x.ReservePlaceholder()); x.WriteCCStringAtPlaceholder(@"", x.ReservePlaceholder(), O3CCSClassTable);
	NSData* dat2 = x.Data();
	STAssertTrue([dat isEqualToData:dat2], @"Somehow the nonlinear writer is not writing key+object headers to specification. %@ != %@", dat, dat2);
}

- (void)testCWriters {
	O3CCStringHint h;
	UInt8* buf = (UInt8*)malloc(1024);
	STAssertTrue(   O3BytesNeededForCCStringWithTable(@"test1",nil)    == O3WriteCCStringWithTableOrIndex(buf,@"test1",nil)      , @"Something is up in O3ArchiveFormat.h");
	STAssertTrue(   O3BytesNeededForCCStringWithTable(@"",nil)         == O3WriteCCStringWithTableOrIndex(buf,@"",nil)           , @"Something is up in O3ArchiveFormat.h");
	STAssertTrue(   O3BytesNeededForCCStringWithTable(@"test1",nil,&h) == O3WriteCCStringWithTableOrIndex(buf,@"test1",nil,&h)   , @"Something is up in O3ArchiveFormat.h");
	STAssertTrue(   O3BytesNeededForCCStringWithTable(@"",nil,&h)      == O3WriteCCStringWithTableOrIndex(buf,@"",nil,&h)        , @"Something is up in O3ArchiveFormat.h");
	STAssertTrue(   O3BytesNeededForCCStringWithTable(@"",nil,&h)      == O3WriteCCStringWithTableOrIndex(buf,@"",nil,&h)        , @"Something is up in O3ArchiveFormat.h");
	STAssertTrue(   O3BytesNeededForCCStringWithTable(nil,nil,&h)      == O3WriteCCStringWithTableOrIndex(buf,nil,nil,&h)        , @"Something is up in O3ArchiveFormat.h");
	free(buf);
}

- (void)testO3KeyedArchiver {
	NSMutableDictionary* md = [NSMutableDictionary new];
	typedef struct {int a; char b;} test_t;
	test_t test; *(UInt64*)&test = 0ull; //NSValue bug radar://5470798
	test.a = 1; test.b = 2;
	[md setObject:[O3Value valueWithVector:O3Vec3d(1,2,3)] forKey:@"vector"];
	[md setObject:[NSNumber numberWithUnsignedChar:0xAA] forKey:@"Some character"];
	[md setObject:[NSMutableData dataWithLength:500] forKey:@"semirandom data"];
	[md setObject:[O3Value valueWithMatrix:O3Mat4x4r()] forKey:@"vector2"];
	[md setObject:[@"/System/Library/Extensions/ACard62xxM.kext/Contents/Resources/English.lproj/InfoPlist.strings" pathComponents] forKey:@"Path array"];
	[md setObject:@"Forty Two!" forKey:@"The Answer"];
	[md setObject:[NSNumber numberWithInt:42] forKey:@"The Answer Translated"];
	[md setObject:[NSNumber numberWithFloat:4.2] forKey:@"4.2"];
 	NSData* dat = [O3KeyedArchiver archivedDataWithRootObject:md];
	NSDictionary* dict2 = [O3KeyedUnarchiver unarchiveObjectWithData:dat];
	if ([dict2 isKindOfClass:[NSDictionary class]]) {
		NSEnumerator* kenum = [md keyEnumerator];
		while (NSString* k = [kenum nextObject]) {
			NSObject* real = [md objectForKey:k];
			NSObject* read = [dict2 objectForKey:k];
			STAssertTrue([real isEqual:read], @"The key \"%@\" was not archived and unarchived consistantly: %@ != %@", k, real, read);
		}
		//STAssertTrue([md isEqualToDictionary:dict2], @"*************************************************\n%@\n***********************!=************************\n%@*************************************************\n%@\n*************************************************", md, dict2,dat);
	} else {
		STAssertTrue(NO, @"NSKeyedUnarchiver unarchiving (%@)%@ is completely screwed up.", [dict2 className], dict2);
	}
	STAssertTrue([md isEqualToDictionary:dict2], @"Unarchiver didn't unarchive the same data that was archived!");
	
	[md release];
}

- (void)testArchivingDate {
	NSDate* now = [NSDate date];
	NSData* dateData = [O3KeyedArchiver archivedDataWithRootObject:now];
	NSDate* then = [O3KeyedUnarchiver unarchiveObjectWithData:dateData];
	STAssertTrue([now isEqual:then], @"Archiving a date failed. (%@)%@ != (%@)%@", [now className], now, [then className], then);
}

- (void)testArchivingCamera {
	O3Camera* c1 = [O3Camera new];
	O3Camera* c2 = [O3Camera new];
	STAssertTrue([c1 isEqual:c2], @"O3Camera's isEqual method is bad");
	[c1 translateBy:O3Translation3(1., 2., 3.)];
	STAssertFalse([c1 isEqual:c2], @"O3Camera's isEqual method is bad");
	NSData* cameraData = [O3KeyedArchiver archivedDataWithRootObject:c1];
	O3Camera* unarchivedCamera = [O3KeyedUnarchiver unarchiveObjectWithData:cameraData];
	STAssertTrue([c1 isEqual:unarchivedCamera], @"Archiving a camera failed. (%@)%@ != (%@)%@", [c1 className], c1, [unarchivedCamera className], unarchivedCamera);
}

- (void)testArchiverCompression {
	NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:@"obj1",@"key1",@"obj2",@"key2",nil];
	NSDictionary* dict2 = [NSDictionary dictionaryWithObjectsAndKeys:dict,@"Key1",dict,@"Key2",dict,@"Key3",nil];
	NSData* dict2data = [O3KeyedArchiver archivedDataWithRootObject:dict2];
	NSDate* data2dict = [O3KeyedUnarchiver unarchiveObjectWithData:dict2data];
	STAssertTrue([data2dict isEqual:dict2], @"Archiving a dictionary failed. %@ != %@", dict2, data2dict);
}

- (void)testArchiverBestCase {
	UIntP count = 100;
	NSMutableDictionary* wdict = [[NSMutableDictionary alloc] init];
	for (UIntP i=0; i<count; i++) {
		NSString* k = [NSString stringWithFormat:@"%p", i];
		NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:[O3Value valueWithVector:O3Vec3r(1,2,3)],@"Location",[O3Value valueWithVector:O3Vec3r(1,2,3)],@"Rotation", [NSNumber numberWithInt:100], @"Awesomeness", nil];
		[wdict setObject:dict forKey:k];
	}
	
	NSMutableData* d1 = [NSMutableData data];
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	O3KeyedArchiver* a1 = [[O3KeyedArchiver alloc] initForWritingWithMutableData:d1];
	[a1 setShouldCompress:NO];
	[a1 encodeObject:wdict forKey:@""];
	[a1 finishEncoding];
	UIntP s1 = [d1 length];	
	[pool release];

	
	NSMutableData* d2 = [NSMutableData data];
	pool = [NSAutoreleasePool new];
	O3KeyedArchiver* a2 = [[O3KeyedArchiver alloc] initForWritingWithMutableData:d2];
	[a2 setShouldCompress:YES];
	[a2 encodeObject:wdict forKey:@""];
	[a2 finishEncoding];
	UIntP s2 = [d2 length];
	[pool release];
	
	NSLog(@"Compression winnage for %i objects is %i-%i = %i = %f%%, or %f rather than %f bytes per object.", count, s1, s2, s1-s2, s2*100./s1, (double)s2/count, (double)s1/count);
	
	[a1 release];
	[a2 release];
	[wdict release];
}

- (void)testStressO3KeyedArchiver {
	NSString* prefs_path = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Preferences"];
	UIntP max_files = 20; //0 for unlimited
	NSFileManager* man = [NSFileManager defaultManager];
	NSEnumerator* pathe = [man enumeratorAtPath:prefs_path];
	UIntP i = 0;
	UInt64 before_size_accum = 0;
	UInt64 after_size_accum = 0;
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	while (NSString* p = [pathe nextObject]) {
		if (![p hasSuffix:@".plist"]) continue;
		if (++i==max_files) break; //0 for unlimited
		if (!(i%20)) {
			[pool release];
			pool = [[NSAutoreleasePool alloc] init];
		}
		NSString* filePath = [prefs_path stringByAppendingPathComponent:p];
		NSDictionary* before = [NSDictionary dictionaryWithContentsOfFile:filePath];
		before_size_accum += [[[man fileAttributesAtPath:filePath traverseLink:NO] objectForKey:NSFileSize] unsignedLongLongValue];
		NSData* dat = [O3KeyedArchiver archivedDataWithRootObject:before];
		NSDictionary* after = [O3KeyedUnarchiver unarchiveObjectWithData:dat];
		after_size_accum += [dat length];
		NSEnumerator* kEnum = [before keyEnumerator];
		NSEnumerator* oEnum = [before objectEnumerator];
		while (NSString* k = [kEnum nextObject]) {
			NSObject* before_obj = [oEnum nextObject];
			NSObject* after_obj  = [after objectForKey:k];
			/*BOOL are_equal = NO;
			if ([before_obj isKindOfClass:[NSDictionary class]])
				are_equal = [(NSDictionary*)before_obj isEqualToDictionary:(NSDictionary*)after_obj];
			else if ([before_obj isKindOfClass:[NSData class]])
				are_equal = [(NSData*)before_obj isEqualToData:(NSData*)after_obj];
			else
				are_equal = [before_obj isEqual:after_obj];*/
			STAssertTrue([before_obj hash]==[after_obj hash] || [before_obj isEqual:after_obj], @"Stress test failed for %@::%@. (%@)%@ != (%@)%@", filePath, k, [before_obj className], before_obj, [after_obj className], after_obj); 
		}
	}
	[pool release];
	NSLog(@"O3Archiver statistics: %i files, %qu bytes before and %qu bytes after. Average %i%% of previous size.", max_files, before_size_accum, after_size_accum, (int)(100*after_size_accum/before_size_accum));
}

@end
