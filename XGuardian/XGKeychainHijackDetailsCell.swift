//
//  XGKeychainHijackDetailsCell.swift
//  XGuardian
//
//  Created by  吴亚冬 on 15/7/7.
//  Copyright (c) 2015年 杭州网蛙科技. All rights reserved.
//

import Cocoa

class XGKeychainHijackDetailsCell: NSTableCellView {

    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        // Drawing code here.
    }
    
    weak var upperView: XGKeychainHijackDetailsView?
    weak var secItem: XGSecurityItem?
    var appFullPath : String?
    
    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
    }
    
    @IBAction func btnRevelAction(sender: AnyObject) {
        self.openAppInFinder(sender)
    }
    
    @IBAction func btnDeleteAction(sender: AnyObject) {
        if let applicationPath = self.appFullPath {
            println("\(secItem)")
            if let secKeyItemRef = self.secItem?.itemRef {
                Keychain.secRemoveApp(itemRef: secKeyItemRef, applicationFullPath: applicationPath)
                //Notifiy cell change
                self.upperView?.tableViewCellChanged()
            }
        }
        return
    }
    
    func openAppInFinder(sender: AnyObject) {
        // let row = self.tableView.rowForView(sender as! NSView)
        if let applicationPath = self.appFullPath {
            NSWorkspace.sharedWorkspace().selectFile(applicationPath, inFileViewerRootedAtPath: "")
        }
        return
    }
    
}
