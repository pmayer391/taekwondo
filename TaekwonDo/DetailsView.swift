//
//  DetailsView.swift
//  TaekwonDo
//
//  Created by Paul Mayer on 10/28/22.
//

import UIKit

//MARK: - Interfaces and Objects
protocol DetailsViewDelegate {
    func detailsViewDismissed()
    func saveNewTask(task: TaekwonTask)
    func editNewTask(task: TaekwonTask)
}

enum TaskType{
    case new, edit, copy
}

class DetailsView: UIView{
    
    @IBOutlet var contentView: UIView!
    @IBOutlet var detailsContainerView: UIView!
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var titleTextField: UITextField!
    @IBOutlet var dueDateTextField: UITextField!
    @IBOutlet var descriptionTextView: UITextView!
    @IBOutlet var btnSave: UIButton!

    let contentWidth = UIScreen.main.bounds.width / 2
    let contentHeight = UIScreen.main.bounds.height / 4
    let halfXScreenSize = UIScreen.main.bounds.width / 2
    let halfYScreenSize = UIScreen.main.bounds.height / 2
    let blurBgView = UIVisualEffectView()
    let datePicker = UIDatePicker(frame: CGRect(x: 0, y: 0, width: 0, height: 200))
    
    var delegate: DetailsViewDelegate?
    var currentTask: TaekwonTask?
    var placeholderTxtView = "Task Description"
    var currentTaskType: TaskType = .new
    
    //MARK: - Init Functions
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    private func configureView(){
        let bundle = Bundle(for: DetailsView.self)
        let nib = UINib(nibName: "DetailsView", bundle: bundle)
        contentView = nib.instantiate(withOwner: self, options: nil)[0] as? UIView
        self.addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        let screenTapGesture = UITapGestureRecognizer(target: self, action: #selector(touchedScreen(_:)))
        self.addGestureRecognizer(screenTapGesture)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardDidHide),
            name: UIResponder.keyboardDidHideNotification,
            object: nil)
        titleTextField.returnKeyType = UIReturnKeyType.done
        titleTextField.delegate = self
        descriptionTextView.delegate = self
        btnSave.isEnabled = false
        descriptionTextView.textColor = UIColor(named: "placeholder")
        if traitCollection.userInterfaceStyle == .light{
            titleTextField.textColor = .black
            dueDateTextField.textColor = .black
        } else {
            titleTextField.textColor = UIColor(named: "tdGold")
            dueDateTextField.textColor = UIColor(named: "tdGold")
        }
        
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .inline
        datePicker.minimumDate = Date()
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        dueDateTextField.inputView = datePicker
    }
    
    //MARK: - Actions
    @IBAction func cancelBtnPressed(_ sender: Any) {
        dismissViewWithAnimation()
    }
    
    @IBAction func saveBtnPressed(_ sender: Any) {
        if currentTaskType != .edit{
            let newTask = TaekwonTask()
            newTask.title = titleTextField.text ?? ""
            newTask.description = descriptionTextView.text
            newTask.dueDate = !((dueDateTextField.text ?? "").isEmpty) ?  datePicker.date : nil
            saveWithAnimation(task: newTask)
        } else {
            guard let currentTask = currentTask else {return}
            currentTask.title = titleTextField.text ?? ""
            currentTask.description = descriptionTextView.text
            currentTask.dueDate = !((dueDateTextField.text ?? "").isEmpty) ?  datePicker.date : nil
            saveWithAnimation(task: currentTask)
        }
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            let yOffset = (UIScreen.main.bounds.height - detailsContainerView.frame.maxY) - keyboardHeight
            if yOffset < 0 {
                UIView.animate(withDuration: 0.35) { [weak self] in
                    guard let strong = self else {return}
                    strong.detailsContainerView.frame = CGRect(
                        x: strong.detailsContainerView.frame.minX,
                        y: strong.detailsContainerView.frame.minY - (abs(yOffset) + 20),
                        width: strong.detailsContainerView.frame.width,
                        height: strong.detailsContainerView.frame.height)
                }
            }
        }
    }
    
    @objc func keyboardDidHide(_ notification: Notification){
        UIView.animate(withDuration: 0.35) { [weak self] in
            self?.detailsContainerView.center.y = 0
        }
    }
    
    @objc func touchedScreen(_ sender: UITapGestureRecognizer){
        titleTextField.resignFirstResponder()
        dueDateTextField.resignFirstResponder()
        descriptionTextView.resignFirstResponder()
    }
    
    @objc func dateChanged(_ sender: UIDatePicker) {
        displaySelectedDate(date: sender.date)
    }
    
    //MARK: - Present & Dismiss view with animation
    func showViewWithAnimation(){
        
        //Populate task if one is passed in
        if (currentTaskType != .new), let task = currentTask {
            titleTextField.text = task.title
            descriptionTextView.text = task.description
            if traitCollection.userInterfaceStyle == .light{
                descriptionTextView.textColor = .black
            } else {
                descriptionTextView.textColor = UIColor(named: "tdGold")
            }

            if let date = task.dueDate{
                datePicker.date = date
                displaySelectedDate(date: date)
            }
        }
        validateInput()
        
        //Set Blur Effect Animation
        var blurBgEffect = UIBlurEffect()
        blurBgEffect = UIBlurEffect(style: .light)
        blurBgView.frame = self.bounds
        blurBgView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.insertSubview(blurBgView, at: 0)
        
        //Set Alpha and Frame/Scale Factor
        self.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.alpha = 0.0
        
        let transform = CGAffineTransform(translationX: 0, y: halfYScreenSize)
        detailsContainerView.transform = transform
        
        UIView.animate(withDuration: 0.25, animations: { [weak self] in
            guard let strong = self else {return}
            strong.blurBgView.effect = blurBgEffect
            strong.alpha = 1.0
            strong.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            
        }) {  [weak self] (complete) in
            UIView.animate(withDuration: 1.55,
                           delay: 0.0,
                           usingSpringWithDamping: 0.5,
                           initialSpringVelocity: 0.5,
                           options: [.curveEaseOut],
                           animations: ({
                self?.detailsContainerView.center.y = 0
            }))
        }
    }
    
    private func dismissViewWithAnimation(){
        UIView.animate(withDuration: 0.15, delay: 0, options: .transitionCurlDown, animations: { [weak self] in
            self?.blurBgView.alpha = 0
            self?.backgroundColor = .clear
        }, completion: { [weak self] finished in
            UIView.animate(withDuration: 0.35, animations: {
                self?.detailsContainerView.center.y = UIScreen.main.bounds.height + (self?.detailsContainerView.frame.height ?? 0) / 2
            }) {[weak self] (complete) in
                self?.removeFromSuperview()
                if let delegate = self?.delegate{
                    delegate.detailsViewDismissed()
                }
            }
        })
    }
    
    private func saveWithAnimation(task: TaekwonTask){
        UIView.animate(withDuration: 0.35, delay: 0, options: .curveLinear, animations: { [weak self] in
            self?.contentView.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            self?.contentView.alpha = 0.0;
        }, completion: { [weak self] finished in
            UIView.animate(withDuration: 0.35, delay: 0.1, options: .curveLinear, animations: { [weak self] in
                self?.blurBgView.alpha = 0
                self?.backgroundColor = .clear
            }) {[weak self] (complete) in
                self?.removeFromSuperview()
                if let delegate = self?.delegate{
                    if self?.currentTaskType == .edit{
                        delegate.editNewTask(task: task)
                    } else {
                        delegate.saveNewTask(task: task)
                    }
                    
                }
            }
        })
    }
    
    //MARK: - Other Functions
    func validateInput(){
        let descriptionText = (descriptionTextView.text == placeholderTxtView) ? "" : descriptionTextView.text ?? ""
        let titleText = titleTextField.text ?? ""
        if !(descriptionText.isEmpty) && !(titleText.isEmpty) {
            btnSave.isEnabled = true
        } else {
            btnSave.isEnabled = false
        }
    }
    
    func displaySelectedDate(date: Date){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yy"
        let dateString = dateFormatter.string(from: date)
        self.dueDateTextField.text = dateString
    }
}

//MARK: - Text Field Functions
extension DetailsView: UITextFieldDelegate{
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        validateInput()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

//MARK: - Text View Functions
extension DetailsView: UITextViewDelegate{
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if descriptionTextView.text == placeholderTxtView{
            descriptionTextView.text = ""
            if traitCollection.userInterfaceStyle == .light{
                descriptionTextView.textColor = .black
            } else {
                descriptionTextView.textColor = UIColor(named: "tdGold")
            }
        }
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let trimmedCharacters = (textView.text).replacingOccurrences(of: "\\s", with: "", options: .regularExpression)
        validateInput()
        if trimmedCharacters.isEmpty && !(descriptionTextView.isFirstResponder){
            descriptionTextView.text = placeholderTxtView
            descriptionTextView.textColor = UIColor(named: "placeholder")
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        let trimmedCharacters = (textView.text).replacingOccurrences(of: "\\s", with: "", options: .regularExpression)
        if trimmedCharacters.isEmpty && !(descriptionTextView.isFirstResponder){
            descriptionTextView.text = placeholderTxtView
            descriptionTextView.textColor = UIColor(named: "placeholder")
        }
    }
}
