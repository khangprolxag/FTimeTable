//
//  WebviewAction.swift
//  FTimeTable
//
//  Created by Khang Ngoc on 9/24/19.
//  Copyright © 2019 Khang Ngoc. All rights reserved.
//

import Foundation
import UIKit
import WebKit

struct Mail {
    let username: String?
    let password: String?
    let campus: String?
}
class WebViewController{
    var mail: Mail!
    var webView: WKWebView!
    
    init(webView: WKWebView, username: String, password: String, campus: String){
        self.mail = Mail(username: username, password: password, campus: campus)
        self.webView = webView
        self.webView.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/77.0.3865.90 Safari/537.36"
        
    }
    
    func handleAfterCampus(){
        webView.evaluateJavaScript("$('#loginform > center > div > div:nth-child(2) > div > div > div').click();", completionHandler: nil)
    }
    
    func handleLogin(){
        let longjs = """
            function waitAndSetValue(inputName, nextButtonid, val){
                var checkExist = setInterval(() => {
                    var inputElement = document.querySelector('[name=' + inputName + ']')
                    if(inputElement){
                        inputElement.value = val;
                        clearInterval(checkExist);
                        document.getElementById(nextButtonid).click();
                    }
                }, 100);
            };
        waitAndSetValue('identifier', 'identifierNext','\(self.mail.username!)');
        waitAndSetValue('password', 'passwordNext', '\(self.mail.password!)');
        
        """
        
        //waitAndSetValue('password','passwordNext','\(self.mail.password!)');
        webView.evaluateJavaScript(longjs, completionHandler: nil)
    }
    
    func handleCampus(){
        //Check if options campus is not selected
        let checkJS = "$('#ctl00_mainContent_ddlCampus').val();"
        webView.evaluateJavaScript(checkJS, completionHandler: {(result, error) in
            print(result as! String)
            if ((result as! String) == self.mail.campus){
                return
            }else{
                let js = "$('#ctl00_mainContent_ddlCampus').val(" + self.mail.campus! + ");" +
                        "__doPostBack('ctl00_mainContent_ddlCampus','');"
                
                self.webView.evaluateJavaScript(js, completionHandler: nil)
                
            }
        })
        
        //======

    }
    
    
    func goTo(url: String){
        let url = URL(string: url)
        var urlRequest = URLRequest(url: url!)
       
        webView.load(urlRequest)
    }

    func injectPopupHandling(){
        self.webView.evaluateJavaScript("window.open = function(open) { return function (url, name, features) { window.location.href = url; return window; }; } (window.open); window.close = function() { window.location.href = 'https://google.com'; }", completionHandler: { (result, error) in
        })
        
    }
    
    
    func clearCache(){
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        print("[WebCacheCleaner] All cookies deleted")
        
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
                print("[WebCacheCleaner] Record \(record) deleted")
            }
        }
    }
    
}
