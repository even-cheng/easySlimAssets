//
//  File.swift
//  easySlimAssets
//
//  Created by 程旭文 on 2021/5/7.
//

import Cocoa

class KeyEventTextField: NSTextField {
    
    private let commandKey = NSEvent.ModifierFlags.command.rawValue

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
    override func performKeyEquivalent(with event: NSEvent) -> Bool {
        
        if (event.modifierFlags.rawValue & event.modifierFlags.intersection(.deviceIndependentFlagsMask).rawValue == commandKey){
          switch event.charactersIgnoringModifiers! {
          case "x":
            NSApp.sendAction(#selector(NSText.cut(_:)), to:nil, from:self)
          case "c":
            NSApp.sendAction(#selector(NSText.copy(_:)), to:nil, from:self)
          case "v":
            NSApp.sendAction(#selector(NSText.paste(_:)), to:nil, from:self)
          case "z":
            NSApp.sendAction(Selector(("undo:")), to:nil, from:self)
          case "a":
            NSApp.sendAction(#selector(NSStandardKeyBindingResponding.selectAll(_:)), to:nil, from:self)
          default:
            break
          }
        }
        
        
        return true
    }
    
}
