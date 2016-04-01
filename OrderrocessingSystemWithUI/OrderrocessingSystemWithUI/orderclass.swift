//
//  orderclass.swift
//  OrderrocessingSystem
//
//  Created by lnwdxs on 16/3/31.
//  Copyright © 2016年 wym. All rights reserved.
//

import Foundation

//--------------order status 参数-----------------
let ORDERPREPARING:Int = 0
let ORDERSCHEDULING:Int = 11
let ORDERPREPROCESSING:Int = 12
let ORDERPROCESSING:Int = 13
let ORDERPOSTPROCESSING:Int = 14
//let ORDERSUCESSED = 3
//let ORDERFAILED = 4
let ORDERFINISH:Int = 2


//--------------order result 参数-----------------
let ORDERRESULTSUCESS = 1
let ORDERRESULTFAIL = 0
/*
let RECORDTABLE = "recordtable"
let RUNNINGTABLE = "runningtable"
let STORAGETABLE = "storagetable"
let UID = "uid"
let ORDERCOM = "ordercom"
let STATUS = "status"
let STARTTIME = "starttime"
let SCHEDUESTARTTIME = "schedueStarttime"
let SCHEDUEENDTIME = "schedueEndtime"
let PREPROCESSSTARTTIME = "preprocessStarttime"
let PREPROCESSENDTIME = "preprocessEndtime"
let PRECESSSTARTTIME = "processStarttime"
let PROCESSENDTIME = "processEndtime"
let POSTPROCESSSTARTTIME = "postprocessStarttime"
let POSTPROCESSENDTIME = "postprocessEndtime"
let COMPLETETIME = "completetime"
let RESULT = "result"
let NODEFORORDER = "nodeForOrder"
let CURSTEP = "curstep"
*/

//order全部运行函数

var curtime = NSDate()
let orderstatusarr = [ORDERPREPARING,ORDERSCHEDULING,ORDERPREPROCESSING,ORDERPROCESSING,ORDERPOSTPROCESSING]

class Order
{
    let command:String
    var uid:Int
    func schedule()->Bool
    {
        //db.execute("update \(RECORDTABLE) set \(STARTTIME) = '\(curtime)',\(SCHEDUESTARTTIME) = '\(curtime)' where '\(UID)' = '\(self.uid)'" )
        db.execute("update recordtable set starttime = '\(NSDate())',schedueStarttime = '\(NSDate())' where uid = '\(self.uid)'")
        db.execute("update runningtable set curstep = '\(ORDERSCHEDULING)' where uid = '\(self.uid)'")
        //db.execute("update '\(RECORDTABLE)' set '\(SCHEDUESTARTTIME)' = '\(NSDate())' where '\(UID)' = '\(self.uid)'" )
       // db.execute("update \(RUNNINGTABLE) set \(CURSTEP) = \(ORDERSCHEDULING) where \(UID) = '\(self.uid)'" )
        sleep(5)
        curtime = NSDate()
        if(arc4random_uniform(100)<5)
        {
            db.execute("update recordtable set completetime = '\(NSDate())',result = 2 where uid = '\(self.uid)'")
            

            return false
        }
        db.execute("update recordtable set schedueEndtime = '\(NSDate())' where uid = '\(self.uid)'")
        return true
    }
    
    func preprocess()->Bool
    {
        db.execute("update recordtable set preprocessStarttime = '\(NSDate())' where uid = '\(self.uid)'")
        db.execute("update runningtable set curstep = '\(ORDERPREPROCESSING)' where uid = '\(self.uid)'")
        sleep(5)
        if(arc4random_uniform(100)<5)
        {
            db.execute("update recordtable set completetime = '\(NSDate())',result = '\(ORDERRESULTFAIL)' where uid = '\(self.uid)'")
            
            
            return false
        }
        db.execute("update recordtable set preprocessEndtime = '\(NSDate())' where uid = '\(self.uid)'")
        return true
    }
    
    func process()->Bool
    {
        db.execute("update recordtable set processStarttime = '\(NSDate())' where uid = '\(self.uid)'")
        db.execute("update runningtable set curstep = '\(ORDERPROCESSING)' where uid = '\(self.uid)'")

        sleep(5)
        if(arc4random_uniform(100)<5)
        {
            db.execute("update recordtable set completetime = '\(NSDate())',result = '\(ORDERRESULTFAIL)' where uid = '\(self.uid)'")
            
            return false
        }
        db.execute("update recordtable set processEndtime = '\(NSDate())' where uid = '\(self.uid)'")
        return true
    }
    
    func postprocess()->Bool
    {
        db.execute("update recordtable set postprocessStarttime = '\(NSDate())' where uid = '\(self.uid)'")
        db.execute("update runningtable set curstep = '\(ORDERPOSTPROCESSING)' where uid = '\(self.uid)'")

        sleep(5)
        if(arc4random_uniform(100)<5)
        {
            db.execute("update recordtable set completetime = '\(NSDate())',result = '\(ORDERRESULTFAIL)' where uid = '\(self.uid)'")
            //print("order id '\(self.uid)' failed \n")
            return false
        }
        db.execute("update recordtable set postprocessEndtime = '\(NSDate())',completetime = '\(NSDate())',result = '\(ORDERRESULTSUCESS)' where uid = '\(self.uid)'")
        
        //let tempnodedata = db.query("select nodeForOrder  from runningtable where uid = '\(self.uid)'")
        //nodecluster[(tempnodedata[0]["nodeForOrder"] as! NSNumber).integerValue].addorder(false)
        //db.execute("delete from runningtable where uid = '\(self.uid)'")
        return true
    }
    
    @objc func run(sender:AnyObject)->Void
    {
        var startstep = sender as! Int
        
        if(orderstatusarr.contains(startstep))
        {
            if((startstep>=11)&&(startstep<=14))
            {
                startstep = startstep%10 - 1
            }
            let steps = [schedule(),preprocess(),process(),postprocess()]
            for(var currentstep=startstep;currentstep<4;currentstep++)
            {
                if(false == steps[currentstep])
                {
                    print("'\(self.uid)' failed \n")
                    break
                }
            }
        }
        //let nodenum = ((db.query("select nodeForOrder from runningtable where uid = '\(self.uid)'"))[0]["runningtable"] as! NSNumber).integerValue
        let tempnodedata = db.query("select nodeForOrder  from runningtable where uid = '\(self.uid)'")
        //var nodeid = (tempnodedata[0]["uid"] as! NSNumber).intValue
        nodecluster[(tempnodedata[0]["nodeForOrder"] as! NSNumber).integerValue].addorder(false)
        db.execute("delete from runningtable where uid = '\(self.uid)'")
        nodecluster[(tempnodedata[0]["nodeForOrder"] as! NSNumber).integerValue].counter -= 1
    }
    
    init(order:String,id:Int)
    {
        self.command = order
        self.uid = id
    }
}