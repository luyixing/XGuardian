//
//  XGSecurityItem.swift
//  XGuardian
//
//  Created by  吴亚冬 on 15/6/24.
//  Copyright (c) 2015年 杭州网蛙科技. All rights reserved.
//

import Cocoa
import Security


/*
Just for GenericPassword and InternetPassword
*/

class XGSecurityItem: NSObject, Printable, DebugPrintable, Equatable, Hashable {

    internal enum ClassType : Printable {
        case InternetPassword
        case GenericPassword
        case Certificate
        case Key
        case Identity
        
        internal func toRaw() -> CFStringRef
        {
            switch self {
            case InternetPassword :return kSecClassInternetPassword
            case GenericPassword  :return kSecClassGenericPassword
            case Certificate      :return kSecClassCertificate
            case Key              :return kSecClassKey
            case Identity         :return kSecClassIdentity
            }
        }
        
        internal static func fromRaw(classType : CFStringRef) -> ClassType
        {
            if( classType == kSecClassInternetPassword) {
                return ClassType.InternetPassword
            } else if (classType == kSecClassGenericPassword) {
                return ClassType.GenericPassword
            } else if (classType == kSecClassCertificate) {
                return ClassType.Certificate
            } else if (classType == kSecClassKey) {
                return ClassType.Key
            } else if (classType == kSecClassIdentity) {
                return ClassType.Identity
            }
            return ClassType.GenericPassword
            /*switch classType {
            case   kSecClassInternetPassword    : return ClassType.InternetPassword
            case   kSecClassGenericPassword 	: return ClassType.GenericPassword
            case   kSecClassCertificate         : return ClassType.Certificate
            case   kSecClassKey                 : return ClassType.Key
            case   kSecClassIdentity            : return ClassType.Identity
            }*/
        }
        
        internal var description: String { get {
            switch self {
            case InternetPassword:          return "Internet password"
            case GenericPassword:           return "generic password"
            case Certificate:               return "certificate"
            case Key:                       return "key"
            case Identity:                  return "identity"
            }
            }}
        
    }
    
//*MARK: -
    
    var name: String?
    var classType: ClassType?
    var account: String?
    var desc: String?
    var createTime: NSDate?
    var modifyTime: NSDate?
    var creator : NSNumber?
    var applicationList: [String]?
    var applicationNum: Int = 0
    var itemRef : SecKeychainItemRef?

    // var accessible : ?
    // var access: SecAccessRef? //kSecAttrAccess
    init(attrDict:NSDictionary) {
        
        
        // lable -> name
        if let label = attrDict[kSecAttrLabel as NSString] as? NSString {
            self.name = label as String
        }
        
        // class - 分类 
        if let kclass  = attrDict[kSecClass as NSString] as? NSString  {
            self.classType = ClassType.fromRaw(kclass as CFStringRef)
        }
        
        // account
        if let account = attrDict[kSecAttrAccount as NSString] as? NSString {
            self.account = account as String
        }
        
        // descprtion
        if let desc = attrDict[kSecAttrDescription as NSString] as? NSString {
            self.desc = desc as String
        }
        
        // create time 
        if let ctime = attrDict[kSecAttrCreationDate as NSString] as? NSDate {
            self.createTime = ctime
        }
        
        // modify time
        if let mtime = attrDict[kSecAttrModificationDate as NSString] as? NSDate {
            self.modifyTime = mtime
        }
        
        // creator "crtr"
        if let creator = attrDict[kSecAttrCreator as NSString] as? NSNumber {
            self.creator = creator
        }
        
        // itemRef
        let item = attrDict["v_Ref"] as! SecKeychainItemRef
        self.itemRef = item
        let appRet = Keychain.secGetAppList(itemRef:item)
        if(appRet.status == Keychain.ResultCode.errSecSuccess){
            if (nil == appRet.appList) || (appRet.appList!.count == 0) {
                self.applicationNum = 0;
            } else if appRet.appList?.first == Keychain.secAuthorizeAllApp {
                self.applicationNum = -1; //any application can accesss
            } else {
                self.applicationNum = appRet.appList!.count;
            }
            self.applicationList = appRet.appList;
        }
        
        
        /*if let access = attrDict[kSecAttrAccess as NSString] as? SecAccessRef {
            self.access = access
        }*/

        super.init()
        return
    }
    
    /**
    Check the key is the same
    
    :param: key another key for check
    
    :returns: ture for same, otherwise is false
    */
    func isSameKey (key: XGSecurityItem?) -> Bool {
        if (nil == key) {
            return false
        } else if (key === self) {
            return true
        }
        
        if( (key!.name == self.name) &&
            (key!.classType == self.classType) &&
            (key!.account == self.account)) {
            return true
        }
        
        return false
    }
    
    override func key() -> String {
        var key = String()
        if(nil != self.name) { key += self.name! }
        if(nil != self.account) { key += self.account! }
        return key
    }
    
    
    override var hashValue: Int { get {
        return self.key().hashValue;
        }
    }
    

    override var description : String {
        var descStr = "Name: \(self.name!)\n";
        if(self.account != nil)  { descStr += "Account: \(self.account!) \n" }
        if(self.classType != nil) { descStr += "Class: \(self.classType!) \n" }
        if(self.desc != nil) { descStr += "Description: \(self.desc!) \n" }
        if(self.createTime != nil) { descStr += "Creation Time: \(self.createTime!) \n" }
        if(self.modifyTime != nil) { descStr += "Modified Time: \(self.createTime!) \n" }
        if(self.creator != nil) {descStr += "Creator: \(self.creator!) \n"}
        
        if(self.applicationNum == -1){
            descStr += "Authorized Applications: Any\n"
        } else if (self.applicationNum == 0) {
            descStr += "Authorized Applications: None\n"
        } else {
            descStr += "Authorized Applications: \n"
            if let al = self.applicationList {
                for str in al {
                    descStr += "        \(str)\n"
                }
            }
        }
        
        return descStr
    }
    

    override var debugDescription : String {
        return self.description
    }
    
}

func == (lhs: XGSecurityItem, rhs: XGSecurityItem) -> Bool {
    let samekey = lhs.isSameKey(rhs)
    if !samekey {
        return false
    }
    
    if (lhs.applicationNum != rhs.applicationNum
        || lhs.createTime != rhs.createTime
        || lhs.creator != rhs.creator) {
        return false
    }
    
    return true;
    
}


