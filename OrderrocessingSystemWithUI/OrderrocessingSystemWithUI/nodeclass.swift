//
//  nodeclass.swift
//  OrderrocessingSystem
//
//  Created by lnwdxs on 16/3/31.
//  Copyright © 2016年 wym. All rights reserved.
//

import Foundation
//var ordercount = 1   //order计数器

class Node
{
    var numserial = -1
    var counter:Int = 0  //node内存在order计数器
    var timer = NSTimer()
    
    //-------------输入中加order--------------------------------
    func addorder(od:Order) -> Bool {
        
        if(counter >= 50)
        {
            return false
        }
        else
        {
           // dbInsertorderrecordwith(od)
            dbInsertorderrunningrecordwith(od, nodenum: self.numserial, curstep: ORDERPREPARING)
            self.counter += 1
            NSThread.detachNewThreadSelector(#selector(od.run(_:)), toTarget: od, withObject: ORDERPREPARING)
            return true
        }
    }
    
    //-------------从storagetable中取order,nodedown已转入nodedownrecovery----------------
    func addorder(nodedown:Bool)->Bool
    {
        if(counter >= 50)
        {
            return false
        }
        else
        {
            var tablesrc = ""
            /*if(nodedown)
            {
                
                tablesrc = "runningtable"
                let countt = db.query("select count(*) from runningtable")
                if((countt[0]["uid"] as! NSNumber).integerValue <= 0)
                {
                    return false
                }
 
            }
            else
            {
 */
                tablesrc = "storagetable"
                let countt = db.query("select count(*) from storagetable")
                if(countt[0]["uid"] == nil)
                {
                    return false
                }
  //          }
            let tempidstep = db.query("select uid from '\(tablesrc)' limit 1")
            let id = ((tempidstep[0])["uid"] as! NSNumber).integerValue
            let step = (tempidstep[0]["curstep"] as! NSNumber).integerValue
            let odcmd = db.query("select ordercom from recordtable where uid ＝ '\(id)'")
            let od = Order(order: (odcmd[0]["ordercom"] as! String),id: id)
           // dbInsertorderrecordwith(od)
  //          if(false == nodedown)
  //          {
                dbInsertorderrunningrecordwith(od, nodenum: self.numserial, curstep: step)
                db.execute("delete from storagetable where uid = '\(id)'")
  //          }
            self.counter += 1
            NSThread.detachNewThreadSelector(#selector(od.run(_:)), toTarget: od, withObject: step)
            return true
        }
    }
    
    //-------------node down 恢复-------------------------
    func nodedownrecovery()->Bool
    {
        let idstepcmds = db.query("select runningtable.uid,runningtable.curstep,recordtable.ordercom from recordtable join runningtable on recordtable.uid = runningtable.uid and runningtable.nodeForOrder = '\(self.numserial)'")
        if(idstepcmds.count != 0)
        {
            for isc in idstepcmds
            {
                let od = Order(order: isc["ordercom"] as! String, id: (isc["uid"] as! NSNumber).integerValue)
                self.counter += 1
                NSThread.detachNewThreadSelector(#selector(od.run(_:)), toTarget: od, withObject: (isc["curstep"] as! NSNumber).integerValue)
            }
        }
        else
        {
            return false
        }
        return true
    }
}
