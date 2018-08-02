import Cocoa

protocol DragDestViewDelegate : class {
    func processFileURL(_ url: URL)
}

class DragDestView: NSView {

    weak var delegate: DragDestViewDelegate?

    override func awakeFromNib() {
        setup()
    }

    func setup() {
        registerForDraggedTypes([.fileURL])
    }
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        return .copy
    }
    
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        let pasteboard = sender.draggingPasteboard()
        let item = pasteboard.pasteboardItems?.first
        if let item = item {
            let file = item.string(forType: .fileURL)
            let fileUrl = URL.init(string: file!)
            if let fileUrl = fileUrl {
                delegate?.processFileURL(fileUrl)
                return true
            }
        }
        return false
    }

    override func hitTest(_ aPoint: NSPoint) -> NSView? {
        return nil
    }
}
