//
//  XGKeyChain.swift
//  XGuardian
//
//  Created by  吴亚冬 on 15/6/23.
//  Copyright (c) 2015年 杭州网蛙科技. All rights reserved.
//

import Cocoa
import CoreFoundation
import Security


private var globalItemSet: XGSecurityItemSet?
private var newItemSet: XGSecurityItemSet?

class XGKeyChain  {
    
    class func getItemSet() ->  XGSecurityItemSet? {
        if nil == globalItemSet {
            globalItemSet = XGKeyChain.scanAllItem()
        }
        return globalItemSet
    }
    
    
    class func getClassAllKey(classValue:Keychain.Query.KSecClassValue ) -> NSArray? {
        let query = Keychain.Query()
        query.kSecClass = classValue
        query.kSecReturnRef = true
        query.kSecReturnAttributes = true
        query.kSecReturnPersistentRef = true
        query.kSecMatchLimit = Keychain.Query.KSecMatchLimitValue.kSecMatchLimitAll
        
        
        let res = Keychain.secItemCopyMatching(query: query)
        assert(res.status == Keychain.ResultCode.errSecSuccess, "SecItemCopyMatching returned success")
        
        println("Status of secItemCopyMatching: \(res.status.toRaw())")
        let r = res.result
        if (r == nil){
            //TODO error process
            return nil
        } else {
            //println("ressult TypeID: \(CFGetTypeID(r)) \(CFCopyTypeIDDescription(CFGetTypeID(r))) Description: \(r)")
        }
        
        let resultArray = r as? NSArray
        if ( r == nil) {
            //TODO error process
            return nil
        }
        //println("ressult Description: \(resultArray)")
        
        return resultArray;
    }
    
    
    class func scanAllItem() -> XGSecurityItemSet {
        
        var itemSet:XGSecurityItemSet = XGSecurityItemSet()
        
        //scan internet password
        let internetPassword = getClassAllKey(Keychain.Query.KSecClassValue.kSecClassInternetPassword)
        if let ip = internetPassword {
            for outDict in ip {
                let item = XGSecurityItem(attrDict: (outDict as? NSDictionary)!)
                itemSet.addItem(item)
                println("\(item)")
            }
        }
        
        //scan generic password
        let genericPassword = getClassAllKey(Keychain.Query.KSecClassValue.kSecClassGenericPassword)
        if let gp = genericPassword { 
            for outDict in gp {
                let item = XGSecurityItem(attrDict: (outDict as? NSDictionary)!)
                itemSet.addItem(item)
                println("\(item)")
            }
        }
        
        return itemSet;
    }
    
}

class XGKeychainTest {
    
    class func test1() -> Bool {
        let q = Keychain.Query()
        q.kSecClass = Keychain.Query.KSecClassValue.kSecClassGenericPassword
        q.kSecAttrDescription = "This is a test description"
        q.kSecAttrGeneric = "Parol".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        q.kSecAttrAccount = "Try1 account-" + "105"
        q.kSecAttrLabel = "Try1 label"
        q.kSecAttrAccessible = Keychain.Query.KSecAttrAccessibleValue.kSecAttrAccessibleAlways
        q.kSecReturnData = true
        q.kSecReturnAttributes = true
        q.kSecReturnRef = true
        q.kSecReturnPersistentRef = true
        
        q.kSecValueData = "Privet".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        
        let res1 = Keychain.secItemAdd(query: q)
        // assert(res1.status == Keychain.ResultCode.errSecSuccess, "SecItemAdd returned success")
        
        println("Keychain secItemAdd returned: \(res1.status)")
        
        if let resUw = res1.result {
            println("res1 TypeID = \(CFGetTypeID(resUw)), Description = \(resUw)")
        } else {
            println("res1 is nil")
        }
        
        let q2 = Keychain.Query()
        q2.kSecAttrAccount = q.kSecAttrAccount
        q2.kSecClass = q.kSecClass
        q2.kSecReturnAttributes = true
        q2.kSecReturnRef = true
        q2.kSecReturnPersistentRef = true
        q2.kSecMatchLimit = Keychain.Query.KSecMatchLimitValue.kSecMatchLimitOne
        
        let res2 = Keychain.secItemCopyMatching(query:q2)
        //assert(res2.status == Keychain.ResultCode.errSecSuccess, "SecItemCopyMatching returned success")
        
        println("Status of secItemCopyMatching: \(res2.status.toRaw())")
        if let r = res2.result
        {
            println("res2 TypeID: \(CFGetTypeID(r)) Description: \(r)")
            let skey = XGSecurityItem(attrDict: (r as? NSDictionary)!)
            println("res2 \(skey)")
        } else {
            println("res2 is nil")
        }
        
        
        //assert(res1.result != nil, "Retreived result is not nil")
        if let r = res1.result {
            if let resultDic = r as? NSDictionary {
                assert(resultDic.objectForKey("acct")!.isEqual(q.kSecAttrAccount!), "Account of the retrieved item matches")
            }
        }
        
        // let res3 = Keychain.secItemDelete(query: q);
        // println("Keychain secItemDelete returned: \(res3)")
        
        
        return true;
        
    }
}