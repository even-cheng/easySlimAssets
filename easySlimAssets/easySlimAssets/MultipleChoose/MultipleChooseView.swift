//
//  MultipleChooseView.swift
//  iConnectStore
//
//  Created by Even on 2019/12/9.
//  Copyright © 2019 com.even_cheng. All rights reserved.
//

import Cocoa
import PathKit

class MultipleChooseView: NSView {
 
    @IBOutlet weak var allChooseButton: NSButton!
    @IBOutlet weak var contentTableView: NSTableView!
    @IBOutlet weak var statusLabel: NSTextField!

    private var all_choosed: Bool = false{
        didSet{
            self.choosedFilePaths.removeAll()
            if all_choosed {
                for filePath in self.allFilePaths {
                    self.choosedFilePaths.append(filePath)
                }
            }
            self.contentTableView.reloadData()
        }
    }
    
    var choosedFilePaths: [String] = [] {
        didSet{
            self.statusLabel.stringValue = "已选择\(choosedFilePaths.count)个文件"
        }
    }
    
    var allFilePaths: [String] = [] {
        didSet{
            self.contentTableView.reloadData()
        }
    }

    var unusedFiles: [FileInfo]?
    var choosedDone: (([String]?)->())?
    var projectPath: String?

    var unusedFilePaths: [String] = [] {
        didSet{
            self.contentTableView.reloadData()
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
        
        self.contentTableView.selectionHighlightStyle = .none
        self.wantsLayer = true
        self.layer!.backgroundColor = NSColor.init(white: 0.28, alpha: 1).cgColor
    }
    
    @IBAction func deleteAction(_ sender: Any) {
        
        if self.unusedFiles == nil || self.choosedFilePaths.count == 0 {
            return
        }
        
        var deleteFiles: [FileInfo] = []
        for file in self.unusedFiles! {
            let name = file.path.string
            if self.choosedFilePaths.contains(name) {
                deleteFiles.append(file)
            }
        }
        
        let (deleted, failed) = FengNiao.delete(deleteFiles)
        guard failed.isEmpty else {
            print("\(unusedFiles!.count - failed.count) unused files are deleted. But we encountered some error while deleting these \(failed.count) files:".yellow.bold)
            for (fileInfo, err) in failed {
                print("\(fileInfo.path.string) - \(err.localizedDescription)")
            }
            return
        }
                
        if let children = try? Path(projectPath!).absolute().children(){
            print("Now Deleting unused Reference in project.pbxproj...⚙".bold)
            for path in children {
                if path.lastComponent.hasSuffix("xcodeproj"){
                    let pbxproj = path + "project.pbxproj"
                    FengNiao.deleteReference(projectFilePath: pbxproj, deletedFiles: deleted)
                }
            }
            print("Unused Reference deleted successfully.".green.bold)
        }
        
        self.allFilePaths.removeAll { (item) -> Bool in
            return self.choosedFilePaths.contains(item)
        }
        self.choosedFilePaths.removeAll()
        self.contentTableView.reloadData()
        self.statusLabel.stringValue = "删除成功"
    }

    @IBAction func allSelectAction(_ sender: NSButton) {
        self.all_choosed = !self.all_choosed
    }
    @IBAction func doneAction(_ sender: Any) {
        if self.choosedDone != nil {
            self.choosedDone!(self.allFilePaths)
        }
        self.removeFromSuperview()
    }
}

extension MultipleChooseView: NSTableViewDelegate {
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        let cellView: MultipleChooseCellView = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "MultipleChooseCell"), owner: self) as! MultipleChooseCellView
        
        cellView.wantsLayer = true
        cellView.layer!.backgroundColor = NSColor.init(white: 0.35, alpha: 1).cgColor
        
        let text: String = self.allFilePaths[row]
        cellView.filePath = text
        
        cellView.choosedBlock = {[weak self] (add:Bool, choosedPath: String?) in
            
            guard choosedPath != nil else {
                return
            }
            if add && self?.choosedFilePaths.contains(choosedPath!) == false {
                self?.choosedFilePaths.append(choosedPath!)
            } else if add == false && self?.choosedFilePaths.contains(choosedPath!) == true {
                self?.choosedFilePaths.removeAll { (item) -> Bool in
                    return item == choosedPath
                }
            }
            self?.contentTableView.reloadData()
        }
        
        let isOn = self.choosedFilePaths.contains(text)
        cellView.choosed = isOn
        
        return cellView
    }
}

extension MultipleChooseView: NSTableViewDataSource {
    
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        
        return self.allFilePaths.count
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        
        return 30
    }
}
