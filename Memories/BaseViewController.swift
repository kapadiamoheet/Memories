//
//  ViewController.swift

import UIKit

class BaseViewController: UIViewController {
    var activityIndicator: UIActivityIndicatorView?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupNavBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func setupNavBar(isTransparentNavColor:Bool = false) {
        navigationItem.largeTitleDisplayMode = .never
        if #available(iOS 13.0, *) {
            self.navigationController?.navigationBar.standardAppearance.configureWithDefaultBackground()
            self.navigationController?.navigationBar.scrollEdgeAppearance?.configureWithDefaultBackground()
        }
    }
    
    func setTitle(_ title:String) {
        self.title = title.uppercased()
    }
}

extension BaseViewController {
    func showSpinner() {
        self.activityIndicator = UIActivityIndicatorView(style: .large)
        if let activity = self.activityIndicator {
            activity.hidesWhenStopped = true
            activity.startAnimating()
            self.view.addSubview(activity)
            self.activityIndicator?.center = self.view.center
            self.view.bringSubviewToFront(activity)
        }
    }
    
    func hideSpinner() {
        self.activityIndicator?.stopAnimating()
        self.activityIndicator?.removeFromSuperview()
    }
}

extension BaseViewController {
    func showAlert(with message:String) {
        let alert = UIAlertController(title: "Memories", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default) { (action) in
            self.dismiss(animated: true, completion: nil)
        }
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func showAlertAndPop(message:String) {
        let alert = UIAlertController(title: "Memories", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default) { (action) in
            self.dismiss(animated: true, completion: nil)
            self.navigationController?.popViewController(animated: true)
        }
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
}
