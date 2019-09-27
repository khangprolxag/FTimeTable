//
//  ViewController.swift
//  FTimeTable
//
//  Created by Khang Ngoc on 9/23/19.
//  Copyright © 2019 Khang Ngoc. All rights reserved.
//s

import UIKit
import WebKit
import SCLAlertView
import ViewAnimator
class ViewController: UIViewController, WKNavigationDelegate, WKUIDelegate, UITableViewDelegate,  UITableViewDataSource {
    
    
    struct Slot {
        var time: String
        var name: String
    }
    struct DateSlots {
        var date: Int
        var slots: [Slot] //Time-Subject
    }
    

    
    
    var timeTable: [String: Array<String>]!
    let idToTime: [Int: String] = [
        0: "7:00-8:30",
        1: "8:45-10:15",
        2: "10:30-12:00",
        3: "12:30-14:00",
        4: "14:15-15:45",
        5: "16:00-17:30",
        6: "17:45-19:15",
        7: "19:30-21:00"
    ]
    var currentDate = DateSlots(date: 0, slots: []) //Init with money and null slot because
    //we haven't fetch data yet

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentDate.slots.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SubjectCell", for: indexPath) as! TableViewCell
        
        let slot = currentDate.slots[indexPath.row]
        
        cell.time.text = slot.time
        cell.time.layer.backgroundColor = #colorLiteral(red: 0.1764042974, green: 0.5356935263, blue: 0.9353654981, alpha: 1)
        cell.time.layer.cornerRadius = 10.0
        
        cell.subject.text = slot.name.replacingOccurrences(of: "\n", with: " ")
        
        if (slot.name.contains("attended")){
            cell.contentView.backgroundColor = #colorLiteral(red: 0.3423779011, green: 0.644826889, blue: 0.06833853573, alpha: 1)
        }else if (slot.name.contains("absent")){
            cell.contentView.backgroundColor = #colorLiteral(red: 0.9267821908, green: 0.3609028459, blue: 0.5879969001, alpha: 1)
        }else if (slot.name.contains("Not yet")){
            cell.contentView.backgroundColor = #colorLiteral(red: 0.9939276576, green: 0.7711419463, blue: 0.1933175325, alpha: 1)
        }
        
        return cell
        
    }
    
    @IBOutlet weak var tableView: UITableView!
    var webView: WKWebView!
    @IBOutlet weak var log: UILabel!
    @IBOutlet weak var userName: UILabel!
    
    var webViewController: WebViewController!
    
    let defaultPage = "http://fap.fpt.edu.vn/Default.aspx"
    let allowedUrlToWeekyTimeTable = [
        "http://fap.fpt.edu.vn/Student.aspx"]
    var step = StepState.SelectCampus
    
    
    enum StepState {
        case SelectCampus
        case Gmail
        case Login
        case HandleAfterCampus
        case RedirectTimeTable
        case GettingTimeTable
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        
        
        
        

    }
    
    override func viewDidAppear(_ animated: Bool) {
        askForGmail()
    }
    
    func askForGmail(){
        let appearance = SCLAlertView.SCLAppearance(
            kTitleFont: UIFont(name: "HelveticaNeue", size: 20)!,
            kTextFont: UIFont(name: "HelveticaNeue", size: 14)!,
            kButtonFont: UIFont(name: "HelveticaNeue-Bold", size: 14)!,
            showCloseButton: false
        )

        // Initialize SCLAlertView using custom Appearance
        let alert = SCLAlertView(appearance: appearance)

        // Creat the subview
        let subview = UIView(frame: CGRect(x: 0,y: 0,width: 300,height: 90))
        let x = (subview.frame.width - 280) / 2

        // Add textfield 1
        let textfield1 = UITextField(frame: CGRect(x: x,y: 10,width: 200,height: 30))
        textfield1.layer.borderColor = UIColor.green.cgColor
        textfield1.layer.borderWidth = 0.5
        textfield1.layer.cornerRadius = 5
        textfield1.placeholder = "Username"
        textfield1.textAlignment = NSTextAlignment.center
        subview.addSubview(textfield1)

        // Add textfield 2
        let textfield2 = UITextField(frame: CGRect(x: x,y: textfield1.frame.maxY + 10,width: 200,height: 30))
        textfield2.isSecureTextEntry = true
        textfield2.layer.borderColor = UIColor.blue.cgColor
        textfield2.layer.borderWidth = 0.5
        textfield2.layer.cornerRadius = 5
        textfield1.layer.borderColor = UIColor.blue.cgColor
        textfield2.placeholder = "Password"
        textfield2.textAlignment = NSTextAlignment.center
        subview.addSubview(textfield2)

        // Add the subview to the alert's UI property
        alert.customSubview = subview
        alert.addButton("Login") {
            
            self.webViewSetup()
            self.webViewController = WebViewController(webView: self.webView,
                                                  username: "khangvnse141026@fpt.edu.vn",
                                                  password: "@KHANG152ace",
                                                  campus: "4")
            
            self.userName.text = self.webViewController.mail.username
            self.webViewController.clearCache()
            self.webViewController.goTo(url: "http://fap.fpt.edu.vn/Report/ScheduleOfWeek.aspx")
            
            self.log.text = "initiate request..."
            
        }
        
        alert.showEdit("FPTU information", subTitle: "Please insert your FPTU email")
    }
    
    @IBAction func onChangeDate(_ sender: UISegmentedControl) {
        updateCurrentDate(Date: sender.selectedSegmentIndex)
    }
    
    func webViewSetup(){
        let webViewConfiguration = WKWebViewConfiguration()
        
        webView = WKWebView(frame: CGRect(x: 0, y: 0, width: 200, height: 800), configuration: webViewConfiguration)
        webView.navigationDelegate = self
        webView.uiDelegate = self
        
        view.addSubview(webView)
        webView.isHidden = true
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        webViewController.injectPopupHandling()
        
        if (step == .RedirectTimeTable){
            
            for allowedUrl in allowedUrlToWeekyTimeTable{
                if (webView.url!.absoluteString.contains(allowedUrl)) {
                    webViewController.goTo(url: "http://fap.fpt.edu.vn/Report/ScheduleOfWeek.aspx")
                    
                    log.text = "Redirect to timetable page"
                    step = .GettingTimeTable
                }
            }
            
        }
        
        decisionHandler(.allow)
    }
 

    var handlingLoginCount = 0
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if (step == .SelectCampus){
            print("handle default page")
            log.text = "selecting campus..."
            webViewController.handleCampus()
            step = .HandleAfterCampus
            
        }else if (step == .HandleAfterCampus){
            print("handle gmail")
            log.text = "handling gmail..."
            webViewController.handleAfterCampus()
            step = .Login
        }else if (step == .Login){
            log.text = "logging into FPTU..."
            if (handlingLoginCount == 3){
                step = .RedirectTimeTable
                webViewController.goTo(url: "http://fap.fpt.edu.vn/Report/ScheduleOfWeek.aspx")
            }
            webViewController.handleLogin()
            handlingLoginCount += 1
            
            //step = .Redirect
        }else if (step == .GettingTimeTable){
            print("yeah it work")
            log.text = "Start to fetch data..."
            webViewController.gettingData({ rawJson, error in
                let jsonData = Data((rawJson as! String).utf8)
                
                do{
                    if let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Array<String>] {
                        
                        self.timeTable = json
                        self.updateCurrentDate(Date: 0) //Monday
                        
                    }
                }catch let err as NSError{
                    print("Failed to load json \(err.localizedDescription)")
                }
            }) //end getting data
        } //end if
        
        
    } //end finish navigation function
    
    func updateCurrentDate(Date: Int){
        guard let timeTable = timeTable else{
            return
        }
        currentDate = DateSlots(date: Date, slots: [])
        var slotNumber = 0
        for slot in timeTable[String(Date)]!{
            if (slot != "-"){
                
                let renamedSlot = slot.replacingOccurrences(of: "(\(idToTime[slotNumber]!))", with: "")
                currentDate.slots.append(Slot(time: idToTime[slotNumber]!, name: renamedSlot))
            }
            slotNumber+=1
        }
        
        UIView.animate(views: tableView.visibleCells,
                       animations: [AnimationType.zoom(scale: -1.0)], delay: 0)
        
        tableView.reloadData()
        
        let fromAnimation = AnimationType.from(direction: .right, offset: 30.0)
        
        let zoomAnimation = AnimationType.zoom(scale: 0.2)
        UIView.animate(views: tableView.visibleCells,
                       animations: [fromAnimation, zoomAnimation, AnimationType.random()], delay: 0.05)
        
        print(currentDate)
    }
   
    



}

