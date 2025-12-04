import Foundation
import UIKit
import NVActivityIndicatorView
import SwiftMessages

class Dialogs {
    
    static func startAnimating(
        _ size: CGSize? = nil,
        message: String? = nil,
        messageFont: UIFont? = nil,
        type: NVActivityIndicatorType? = nil,
        color: UIColor? = nil,
        padding: CGFloat? = nil,
        displayTimeThreshold: Int? = nil,
        minimumDisplayTime: Int? = nil,
        backgroundColor: UIColor? = nil,
        textColor: UIColor? = nil,
        fadeInAnimation: FadeInAnimation? = NVActivityIndicatorView.DEFAULT_FADE_IN_ANIMATION) {
        let activityData = ActivityData(size: size,
                                        message: message,
                                        messageFont: messageFont,
                                        type: type,
                                        color: color,
                                        padding: padding,
                                        displayTimeThreshold: displayTimeThreshold,
                                        minimumDisplayTime: minimumDisplayTime,
                                        backgroundColor: backgroundColor,
                                        textColor: textColor)
        
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData, fadeInAnimation)
    }
    
    static func dismiss(){
        DispatchQueue.main.async {
            NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
        }
    }
    
    static func showLoading(_ message:String? = nil){
        DispatchQueue.main.async {
            NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
            if let text = message {
                Dialogs.startAnimating(CGSize(width: 60, height: 60), message: text, messageFont: UIFont.systemFont(ofSize: 14), type: .ballRotateChase, color: .white, padding: 0, displayTimeThreshold: nil, minimumDisplayTime: nil, backgroundColor: nil, textColor: .white, fadeInAnimation: nil)
            }else {
                Dialogs.startAnimating(CGSize(width: 60, height: 60), message: NSLocalizedString("Loading...", comment: ""), messageFont: UIFont.systemFont(ofSize: 14), type: .ballRotateChase, color: .white, padding: 0, displayTimeThreshold: nil, minimumDisplayTime: nil, backgroundColor: nil, textColor: .white, fadeInAnimation: nil)
            }
        }
    }
    
    
    static func showSuccess(_ message:String? = nil, duration: Int = 2){
        DispatchQueue.main.async {
            NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
            if let text = message {
                showSwiftNotificationMessage("", text, theme: .success, duration: TimeInterval(duration))
            }else {
                showSwiftNotificationMessage("", "", theme: .success, duration: TimeInterval(duration))
            }
        }
    }
    
    static func showError(_ message:String? = nil, duration: Int = 2){
        DispatchQueue.main.async {
            NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
            if let text = message {
                showSwiftNotificationMessage("", text, theme: .error, duration: TimeInterval(duration))
            }else {
                showSwiftNotificationMessage("", "", theme: .error, duration: TimeInterval(duration))
            }
        }
    }
    
    static func showWarning(_ message:String? = nil, duration: Int = 2){
        DispatchQueue.main.async {
            NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
            if let text = message {
                showSwiftNotificationMessage("", text, theme: .warning, duration: TimeInterval(duration))
            }else {
                showSwiftNotificationMessage("", "", theme: .warning, duration: TimeInterval(duration))
            }
        }
    }
}

func showSwiftNotificationMessage(_ title: String, _ body: String, theme: Theme, duration: TimeInterval = 2){
    let swiftMsgView = MessageView.viewFromNib(layout: .cardView)
    swiftMsgView.configureTheme(theme)
    swiftMsgView.configureDropShadow()
    swiftMsgView.configureContent(title: title, body: body)
    swiftMsgView.titleLabel?.font = UIFont.systemFont(ofSize: 18)
    swiftMsgView.bodyLabel?.font = UIFont.systemFont(ofSize: 15)
    swiftMsgView.button?.isHidden = true
    var swiftMsgConfig = SwiftMessages.defaultConfig
    swiftMsgConfig.presentationStyle = .top
    swiftMsgConfig.presentationContext = .window(windowLevel: UIWindow.Level.statusBar)
    swiftMsgConfig.duration = .seconds(seconds: duration)
    SwiftMessages.show(config: swiftMsgConfig, view: swiftMsgView)
}
