//
//  WebViewController.swift
//  LinkMoa
//
//  Created by Beomcheol Kwon on 2021/03/19.
//

import UIKit
import WebKit

class WebViewController: UIViewController, CustomActivityDelegate {
    
    @IBOutlet weak var backwardButton: UIButton!
    @IBOutlet weak var forwardButton: UIButton!
    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var closeButton: UIButton!
    
    var url: URL = URL(string: "https://apple.com")!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateButtonState()
        prepareWebView(url: url)
        webView.navigationDelegate = self
    }
    
    static func storyboardInstance() -> WebViewController? {
        let storyboard = UIStoryboard(name: WebViewController.storyboardName(), bundle: nil)
        return storyboard.instantiateInitialViewController()
    }
    
    private func prepareWebView(url: URL) {
        let request = URLRequest(url: url)
        webView.load(request)
        urlTextField.text = url.absoluteString
        
    }
    
    
    @IBAction func backwardButtonTapped(_ sender: Any) {
        if webView.canGoBack {
            webView.goBack()
        }
    }
    
    @IBAction func forwardButtonTapped(_ sender: Any) {
        if webView.canGoForward {
            webView.goForward()
        }
    }
    
    @IBAction func refreashButtonTapped(_ sender: Any) {
        webView.reload()
    }
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func shareButtonTapped(_ sender: Any) {
        if let url = webView.url?.absoluteURL {
            let customActivity = CustomActivity()
            customActivity.delegate = self
            let activityController = UIActivityViewController(activityItems: [url], applicationActivities: [customActivity])
    
            self.present(activityController, animated: true, completion: nil)
        }
    }
    
    func performActionCompletion(actvity: CustomActivity) {
        guard let url = webView.url?.absoluteURL, UIApplication.shared.canOpenURL(url) else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    
    
    
    func updateButtonState() {
        print(#function)
        if webView.canGoBack {
            backwardButton.tintColor = .black
        } else {
            backwardButton.tintColor = UIColor(rgb: 0xc1c1c1)
        }
        
        if webView.canGoForward {
            forwardButton.tintColor = .black
        } else {
            forwardButton.tintColor = UIColor(rgb: 0xc1c1c1)
        }
    }
}


extension WebViewController: WKUIDelegate, WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        updateButtonState()
        if let url = webView.url?.absoluteString {
            urlTextField.text = url
        }
    }
}
