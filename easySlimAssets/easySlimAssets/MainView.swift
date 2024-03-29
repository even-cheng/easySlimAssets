//
//  ViewController.swift
//  ChangeIcon
//
//  Created by 程旭文 on 2021/4/30.
//

import Cocoa

class MainView: NSView {

    @IBOutlet weak var target_h: NSButton!
    @IBOutlet weak var target_m: NSButton!
    @IBOutlet weak var target_mm: NSButton!
    @IBOutlet weak var target_swift: NSButton!
    @IBOutlet weak var target_xib: NSButton!
    @IBOutlet weak var target_css: NSButton!
    @IBOutlet weak var target_plist: NSButton!
    @IBOutlet weak var target_html: NSButton!
    @IBOutlet weak var target_json: NSButton!
    @IBOutlet weak var target_sb: NSButton!
    @IBOutlet weak var target_more: NSTextField!
    
    @IBOutlet weak var check_imageset: NSButton!
    @IBOutlet weak var check_png: NSButton!
    @IBOutlet weak var check_jpg: NSButton!
    @IBOutlet weak var check_gif: NSButton!
    @IBOutlet weak var check_pdf: NSButton!
    @IBOutlet weak var check_more: NSTextField!
    
    @IBOutlet weak var statusField: NSTextField!
    @IBOutlet weak var sourceProjectView: NSButton!
    @IBOutlet weak var showbutton: NSButton!
    
    @IBOutlet weak var excludeField: NSTextField!
    
    private var fileTypeIsOk = false
    
    private var projectPath: String?
    private var unusedFiles: [FileInfo]?

    private var targetTypes: [String]?
    private var checkTypes: [String]?

    //MARK: Functions
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        if #available(OSX 10.13, *) {
            registerForDraggedTypes([NSPasteboard.PasteboardType.fileURL, NSPasteboard.PasteboardType.URL])
        } else {
            // Fallback on earlier versions
        }
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        if #available(OSX 10.13, *) {
            registerForDraggedTypes([NSPasteboard.PasteboardType.fileURL, NSPasteboard.PasteboardType.URL])
        } else {
            // Fallback on earlier versions
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.wantsLayer = true
        self.layer!.backgroundColor = NSColor(red:0.3, green:0.3, blue:0.3, alpha:1.00).cgColor
    }
    
    private func fileDropped(_ filename: String){
        let extensionPathUrl = URL(fileURLWithPath: filename)
        statusField.stringValue = "已选择项目文件";
        sourceProjectView.title = extensionPathUrl.pathComponents.last!
        projectPath = filename
        self.showbutton.isHidden = true
    }

    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        if checkExtension(sender) == true {
            self.fileTypeIsOk = true
            return .copy
        } else {
            self.fileTypeIsOk = false
            return NSDragOperation()
        }
    }
    
    override func draggingUpdated(_ sender: NSDraggingInfo) -> NSDragOperation {
        if self.fileTypeIsOk {
            return .copy
        } else {
            return NSDragOperation()
        }
    }
    
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        let pasteboard = sender.draggingPasteboard
        if let board = pasteboard.propertyList(forType: NSPasteboard.PasteboardType(rawValue: "NSFilenamesPboardType")) as? NSArray {
            if let filePath = board[0] as? String {
                fileDropped(filePath)
                return true
            }
        }
        return false
    }
    
    private func checkExtension(_ drag: NSDraggingInfo) -> Bool {
        if let board = drag.draggingPasteboard.propertyList(forType: NSPasteboard.PasteboardType(rawValue: "NSFilenamesPboardType")) as? NSArray,
            let path = board[0] as? String {
            
            var isDir: ObjCBool = false
            let exist = FileManager.default.fileExists(atPath: path, isDirectory: &isDir)
            return exist && isDir.boolValue
        }
        return false
    }
    
    @IBAction func checkProject(_ sender: Any) {
        if projectPath == nil {
            statusField.stringValue = "项目文件不存在";
            return
        }
        statusField.stringValue = "正在检查，这可能需要一点时间，请稍等...";

        var excludePaths: [String] = []
        let excludeNames = excludeField.stringValue.components(separatedBy: ",")
        for exclude in excludeNames {
            excludePaths.append(exclude)
        }

        let resourceExtentions = getAllowCheckFile()
        let fileExtensions = getAllowTargets()

        var fengNiao = FengNiao(projectPath: projectPath!,
                                excludedPaths: excludePaths,
                                resourceExtensions: resourceExtentions,
                                searchInFileExtensions: fileExtensions)
        fengNiao.searchProgress = {[weak self] (filename: String) in
            DispatchQueue.main.async {
                self?.statusField.stringValue = "正在检查: \(filename)"
            }
        }
        DispatchQueue.global().async {
            self.unusedFiles = try! fengNiao.unusedFiles()
            if self.unusedFiles!.isEmpty {
                DispatchQueue.main.async {
                    self.statusField.stringValue = "恭喜你，没有多余的资源文件".green.bold
                }
                return
            }
            
            DispatchQueue.main.async {
                self.showbutton.isHidden = false
            
                let memory = self.calculateMemorySizeWithUnusedFiles()
                self.statusField.stringValue = "共发现\(self.unusedFiles!.count)个未引用素材, 占用\(memory)MB空间，点击处理 ->"
            }
        }
    }

    private func getAllowTargets() -> [String] {

        var targets: [String] = []
        if target_h.state == .on {
            targets.append("h")
        }
        if target_m.state == .on {
            targets.append("m")
        }
        if target_mm.state == .on {
            targets.append("mm")
        }
        if target_swift.state == .on {
            targets.append("swift")
        }
        if target_xib.state == .on {
            targets.append("xib")
        }
        if target_sb.state == .on {
            targets.append("storyboard")
        }
        if target_plist.state == .on {
            targets.append("plist")
        }
        if target_html.state == .on {
            targets.append("html")
        }
        if target_json.state == .on {
            targets.append("json")
        }
        if target_css.state == .on {
            targets.append("css")
        }
        let more = target_more.stringValue;
        let moreTarget = more.components(separatedBy: ",")
        for tar in moreTarget {
            targets.append(tar)
        }
        
        return targets
    }
    
    private func getAllowCheckFile() -> [String] {

        var checks: [String] = []
        if check_imageset.state == .on {
            checks.append("imageset")
        }
        if check_jpg.state == .on {
            checks.append("jpg")
        }
        if check_png.state == .on {
            checks.append("png")
        }
        if check_gif.state == .on {
            checks.append("gif")
        }
        if check_pdf.state == .on {
            checks.append("pdf")
        }
       
        let more = check_more.stringValue;
        let moreCheck = more.components(separatedBy: ",")
        for check in moreCheck {
            checks.append(check)
        }
        
        return checks
    }
    
    private func calculateMemorySizeWithUnusedFiles() -> String{
        
        var size: Double = 0.0
        for file in self.unusedFiles! {
            size += Double(file.size)
        }
        let memory = String (format: "%.2f" , size/1024/1024)
        return memory
    }
    
    @IBAction func showResult(_ sender: Any) {
     
        var allFilePaths: [String] = []
        for file in unusedFiles! {
            let name = file.path.string
            allFilePaths.append(name)
        }
        let editView = viewForXIB(class_name: "MultipleChooseView") as! MultipleChooseView
        editView.allFilePaths = allFilePaths
        editView.unusedFiles = unusedFiles!
        editView.projectPath = projectPath
        editView.choosedDone = {[weak self] (choosed: [String]?) in
            self?.isHidden = false

            guard choosed != nil else {return}
            if choosed?.count != self?.unusedFiles?.count {
                self?.unusedFiles?.removeAll(where: { (item) -> Bool in
                    let name = item.path.string
                    return choosed!.contains(name) == false
                })
                if choosed!.count == 0 {
                    self?.statusField.stringValue = "清理成功。恭喜您，现在已经是最佳状态"
                    self?.showbutton.isHidden = true
                } else {
                    self?.showbutton.isHidden = false
                    
                    let memory = self!.calculateMemorySizeWithUnusedFiles()
                    self?.statusField.stringValue = "清理成功。剩余\(choosed!.count)个未引用素材, 占用\(memory)MB空间, 继续处理 ->"
                }
            }
        }
        guard let contentView = self.superview else {return}
        self.isHidden = true
        contentView.addSubview(editView)
        
        editView.translatesAutoresizingMaskIntoConstraints = false
        let constraintLeading:NSLayoutConstraint = NSLayoutConstraint(item: editView, attribute:  NSLayoutConstraint.Attribute.leading, relatedBy:NSLayoutConstraint.Relation.equal, toItem:contentView, attribute:NSLayoutConstraint.Attribute.leading, multiplier:1.0, constant: 0)
        let constraintTrailing:NSLayoutConstraint = NSLayoutConstraint(item: editView, attribute:  NSLayoutConstraint.Attribute.trailing, relatedBy:NSLayoutConstraint.Relation.equal, toItem:contentView, attribute:NSLayoutConstraint.Attribute.trailing, multiplier:1.0, constant: 0)
        let constraintTop:NSLayoutConstraint = NSLayoutConstraint(item: editView, attribute:  NSLayoutConstraint.Attribute.top, relatedBy:NSLayoutConstraint.Relation.equal, toItem:contentView, attribute:NSLayoutConstraint.Attribute.top, multiplier:1.0, constant: 0)
        let constraintBottom:NSLayoutConstraint = NSLayoutConstraint(item: editView, attribute:  NSLayoutConstraint.Attribute.bottom, relatedBy:NSLayoutConstraint.Relation.equal, toItem:contentView, attribute:NSLayoutConstraint.Attribute.bottom, multiplier:1.0, constant: 0)
        editView.superview!.addConstraint(constraintLeading)
        editView.superview!.addConstraint(constraintTrailing)
        editView.superview!.addConstraint(constraintBottom)
        editView.superview!.addConstraint(constraintTop)
    }
}


extension NSView {
    
    func viewForXIB(class_name: String) -> NSView?{
        
        let xib = NSNib.init(nibNamed: class_name, bundle: nil)
        var views: NSArray?
        xib!.instantiate(withOwner: nil, topLevelObjects: &views)
        for view in views! {
            if let editView = view as? NSView {
                return editView
            }
        }
        return nil
    }
}


