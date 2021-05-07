//
//  MultipleChooseCellView.swift
//  easySlimAssets
//
//  Created by 程旭文 on 2021/5/7.
//
import Cocoa

class MultipleChooseCellView: NSTableCellView {
    
    var choosedBlock: ((Bool, String?)->())?

    @IBOutlet weak var chooseButton: NSButton!
    @IBOutlet weak var cellField: NSTextField!

    var choosed: Bool = false {
        didSet{
            if choosed {
                self.chooseButton?.state = .on
            } else {
                self.chooseButton?.state = .off
            }
        }
    }
    
    var filePath: String? {
        didSet{
            self.cellField?.stringValue = filePath!
        }
    }
    
    //MARK: Functions
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()        
    }
    
    @IBAction func showDetailAction(_ sender: Any) {
        guard filePath != nil else {return}
        
        NSWorkspace.shared.activateFileViewerSelecting([URL(fileURLWithPath: filePath!)])
        print("show unused file at: \(filePath!)")
    }
    
    @IBAction func chooseAction(_ sender: NSButton) {
        if self.choosedBlock != nil {
            let add = sender.state == .on
            self.choosedBlock!(add, filePath)
        }
    }
}
