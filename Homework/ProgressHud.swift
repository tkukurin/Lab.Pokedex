import SVProgressHUD

class ProgressHud {
    
    static func show() {
        SVProgressHUD.show()
    }
    
    static func indicateFailure(status: String = "") {
        SVProgressHUD.showErrorWithStatus(status)
    }
    
    static func indicateSuccess(status: String = "") {
        SVProgressHUD.showSuccessWithStatus(status)
    }
    
    static func dismiss() {
        SVProgressHUD.dismiss()
    }
    
}