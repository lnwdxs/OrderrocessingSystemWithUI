//
//  ViewController.swift
//  OrderrocessingSystemWithUI
//
//  Created by lnwdxs on 16/4/1.
//  Copyright © 2016年 wym. All rights reserved.
//

import UIKit
var nodecluster = [Node]()
var mainpointer = UIViewController()

class ViewController: UIViewController {
    var ordercount = 0
    
    var signal = [NSDate]()
    var timerforchecknode = NSTimer()
    //let tensec = NSDate(timeIntervalSinceNow: 10).timeIntervalSinceDate(NSDate())
    
    @IBOutlet weak var ordertextfield: UITextField!
    @IBOutlet weak var querytextfield: UITextField!
    @IBOutlet weak var orderandidTextfield: UITextView!
    @IBOutlet weak var queryresultTextfield: UITextView!
    
    
    //---------------初始化数据库几个参数加入计时器定时检查node是否down----------------
    override func viewDidLoad() {
        super.viewDidLoad()
        mainpointer = self
        dbinit()
        for(var i=0;i<10;i++)
        {
            let newnode = Node()
            signal.append(NSDate())
            newnode.numserial = i
            newnode.timer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: #selector(ViewController.sendmsg(_:)), userInfo: i, repeats: true)
            nodecluster.append(newnode)
        }
        timerforchecknode = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: #selector(ViewController.checknode), userInfo: nil, repeats: true)
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func sendmsg(t:NSTimer)       //node信号函数
    {
        signal[t.userInfo as! Int] = NSDate()
        //print(signal[t.userInfo as! Int])
    }
    
    func checknode()            //检查node是否down的函数，down后recovery
    {
        for(var i=0;i<signal.count;i++)
        {
            if(NSDate().timeIntervalSinceDate(signal[i]) > 10)
            {
                print("node '\(i)' is down,create a new one")
                let newnode = Node()
                signal.append(NSDate())
                newnode.numserial = i
                newnode.timer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: #selector(ViewController.sendmsg(_:)), userInfo: i, repeats: true)
                nodecluster[i] = newnode
                nodecluster[i].nodedownrecovery()
                print("new node created")
            }
        }
        
    }
    
    @IBAction func sendorderbtnTouched(sender: UIButton)  //send按钮触发函数，数据输入
    {
        ordercount++
        let od = Order(order: self.ordertextfield.text!,id: ordercount)
        dbInsertorderrecordwith(od)
        var count = 0
        for(;count<nodecluster.count;count++)
        {
            if(true == nodecluster[count].addorder(od))
            {
                
                //dbInsertorderrunningrecordwith(od, nodenum: count, curstep: 0)
                break
            }
        }
        if(count>=nodecluster.count)
        {
            dbInsertorderstoragerecordwith(od, curstep: 0)
        }
        self.orderandidTextfield.text = String(self.orderandidTextfield.text + "order:'\(od.command)'..orderid:'\(od.uid)' \n")
    }
    @IBAction func querybtnTouched(sender: UIButton) //用户查询函数
    {
        let id = (self.querytextfield.text! as NSString).integerValue
        if(id<=0 || id>self.ordercount)
        {
            return
        }
        let queryresult = (db.query("select * from recordtable where uid = '\(id)'"))
        let uid = (queryresult[0]["uid"] as! NSNumber).integerValue
        let ordercom = queryresult[0]["ordercom"]!
        let status = (queryresult[0]["status"] as! NSNumber).stringValue
        let starttime = queryresult[0]["starttime"]
        let schedueStarttime = queryresult[0]["schedueStarttime"]
        let schedueEndtime = queryresult[0]["schedueEndtime"]
        let preprocessStarttime = queryresult[0]["preprocessStarttime"]
        let preprocessEndtime = queryresult[0]["preprocessEndtime"]
        let processStarttime = queryresult[0]["processStarttime"]
        let processEndtime = queryresult[0]["processEndtime"]
        let postprocessStarttime = queryresult[0]["postprocessStarttime"]
        let postprocessEndtime = queryresult[0]["postprocessEndtime"]
        let completetime = queryresult[0]["completetime"]
        let result = (queryresult[0]["result"] as! NSNumber).stringValue
        self.queryresultTextfield.text = String(self.queryresultTextfield.text + "uid:'\(uid)',ordercom:'\(ordercom)',status:'\(status)',starttime:'\(starttime)',schedueStarttime:'\(schedueStarttime)',schedueEndtime:'\(schedueEndtime)',preprocessStarttime:'\(preprocessStarttime)',preprocessEndtime:'\(preprocessEndtime)',processStarttime:'\(processStarttime)',processEndtime:'\(processEndtime)',postprocessStarttime:'\(postprocessStarttime)',postprocessEndtime:'\(postprocessEndtime)',completetime:'\(completetime)',result:'\(result)'" + "\n")
        //print(db.query("select * from recordtable where uid = '\(id)'"))
    }


}

