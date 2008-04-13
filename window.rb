@w = NSWindow.alloc.initWithContentRect_styleMask_backing_defer(NSRect.new(100,100,800,600), NSTitledWindowMask | NSClosableWindowMask | NSMiniaturizableWindowMask | NSResizableWindowMask, NSBackingStoreBuffered, false)
@o = O3GLView.alloc.initWithFrame NSRect.new(0,0,500,500)
@w.setContentView @o
@w.makeFirstResponder @o
@o.installDefaultViewController
@o.setDefaultScene
@w.makeKeyAndOrderFront nil
@w.setReleasedWhenClosed true
@o.release