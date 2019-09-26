//
//  ViewController.swift
//  FTimeTable
//
//  Created by Khang Ngoc on 9/23/19.
//  Copyright © 2019 Khang Ngoc. All rights reserved.
//s

import UIKit
import WebKit
class ViewController: UIViewController, WKNavigationDelegate, WKUIDelegate {

    
    @IBOutlet weak var webView: WKWebView!
    
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
        case Redirect
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        webView.navigationDelegate = self
        webView.uiDelegate = self
        
        
        
        webViewController = WebViewController(webView: webView,
                                              username: "khangvnse141026@fpt.edu.vn",
                                              password: "@KHANG152ace",
                                              campus: "4")
        
        webViewController.clearCache()
        webViewController.goTo(url: "http://fap.fpt.edu.vn/Report/ScheduleOfWeek.aspx")

    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        webViewController.injectPopupHandling()
        
        if (step == .Redirect){
            print("redirect")
            
            for allowedUrl in allowedUrlToWeekyTimeTable{
                if (webView.url!.absoluteString.contains(allowedUrl)) {
                    webViewController.goTo(url: "http://fap.fpt.edu.vn/Report/ScheduleOfWeek.aspx")
                }
            }
            
        }
        
        decisionHandler(.allow)
    }
 

    var handlingLoginCount = 0
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if (step == .SelectCampus){
            print("handle default page")
            webViewController.handleCampus()
            step = .HandleAfterCampus
            
        }else if (step == .HandleAfterCampus){
            print("handle gmail")
            webViewController.handleAfterCampus()
            step = .Login
        }else if (step == .Login){
            if (handlingLoginCount == 3){
                step = .Redirect
                webViewController.goTo(url: "http://fap.fpt.edu.vn/Report/ScheduleOfWeek.aspx")
            }
            webViewController.handleLogin()
            handlingLoginCount += 1
            
            //step = .Redirect
        }
        
        
 
    }
   
    



}

