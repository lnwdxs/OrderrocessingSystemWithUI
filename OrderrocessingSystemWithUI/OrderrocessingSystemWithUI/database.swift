//
//  database.swift
//  OrderrocessingSystem
//
//  Created by lnwdxs on 16/3/31.
//  Copyright © 2016年 wym. All rights reserved.
//
import Foundation
//import "OrderrocessingSystem-Bridging-Header.h"
var db = SQLiteDB(gid: "")


func dbinit()   //数据库初始化，为方便测试每次运行都重置db
{
    let filemanage = NSFileManager.defaultManager()
    let docDir = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
    let path = (docDir as NSString).stringByAppendingPathComponent("data.db")
    //if !(filemanage.fileExistsAtPath(path))
    //{
        filemanage.createFileAtPath(path, contents: nil, attributes: nil)
    //}
    
    
    db = SQLiteDB.sharedInstance()
    
    
    db.execute("create table if not exists recordtable(uid integer primary key,ordercom text,status integer,starttime text,schedueStarttime text,schedueEndtime text,preprocessStarttime text,preprocessEndtime text,processStarttime text,processEndtime text,postprocessStarttime text,postprocessEndtime text,completetime text,result boolean)")
    db.execute("create table if not exists runningtable(uid integer primary key,nodeForOrder integer,curstep integer) ")
    db.execute("create table if not exists storagetable(uid integer primary key,curstep integer)")
    //db.execute("insert into recordtable(uid,ordercom,status,starttime,schedueStarttime,schedueEndtime,preprocessStarttime,preprocessEndtime,processStarttime,processEndtime,postprocessStarttime,postprocessEndtime,completetime,result) values(0,'-1',-1,'-1','-1','-1','-1','-1','-1','-1','-1','-1','-1',-1)")
    //let data = db.query("select * from recorddb")
    //print(data)
}

func dbInsertorderrecordwith(od:Order)      //记录所有order细节
{
    db.execute("insert into recordtable(uid,ordercom) values('\(od.uid)','\(od.command)')")
}

func dbInsertorderrunningrecordwith(od:Order,nodenum:Int,curstep:Int)  //记录node中order
{
    db.execute("insert into runningtable(uid,nodeForOrder,curstep) values('\(od.uid)','\(nodenum)',0)")
}

func dbInsertorderstoragerecordwith(od:Order,curstep:Int)       //存盘准备运行的order
{
    db.execute("insert into storagetable(uid,curstep) values('\(od.uid)','\(curstep)')")
}

