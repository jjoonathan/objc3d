@w = NSWindow.alloc.initWithContentRect_styleMask_backing_defer(NSRect.new(100,100,800,600), NSTitledWindowMask | NSClosableWindowMask | NSMiniaturizableWindowMask | NSResizableWindowMask, NSBackingStoreBuffered, false)
@w.makeKeyAndOrderFront nil
@o = O3GLView.alloc.initWithFrame NSRect.new(0,0,500,500)
@w.setContentView @o