//
//  JJRichTextEditor.swift
//  RichEditorViewSample
//
//  Created by Jack on 28/8/17.
//  Copyright © 2017 Caesar Wirth. All rights reserved.
//
import UIKit
import IGColorPicker
import RichEditorView
import SCLAlertView

enum ColorEditMode {
    case background
    case text
}

open class JJRichTextEditor: UIView {

    //Editor
    public var editorView: RichEditorView! {
        didSet {
            //Init editor
            editorView.delegate = self
            editorView.inputAccessoryView = self
            
            //Init toolbar
            toolbar.delegate = self
            toolbar.editor = editorView
            self.addSubview(toolbar)
            
            //Init Color Picker
            colorPickerView.layoutDelegate = self
            colorPickerView.delegate = self
            self.addSubview(colorPickerView)
            
            // We will create a custom action that clears all the input text when it is pressed		
            let item = RichEditorOptionItem(image: nil, title: "compress") { toolbar in
                toolbar.editor?.html = ""		
            }		
            		
            var options = toolbar.options		
            options.append(item)		
            toolbar.options = options
        }
    }
    public var htmlTextView: UITextView!
    public var doubleRows: Bool = false {
        willSet {
            toolbar.doubleRows = newValue
            if(newValue) {
                toolbar.options = RichEditorDefaultOption.firstRow
                toolbar.secondaryOptions = RichEditorDefaultOption.secondRow
                colorDotWidth = self.frame.height / 2 - 20
                colorPickerView = {
                    let colorPickerView = ColorPickerView(frame: CGRect(x:  0, y: -self.frame.height, width: self.bounds.width, height: self.frame.height))
                    colorPickerView.selectionStyle = .none
                    colorPickerView.layer.shadowColor = UIColor.clear.cgColor
                    colorPickerView.layer.shadowOffset = CGSize.zero
                    colorPickerView.layer.shadowOpacity = 0.7
                    colorPickerView.layer.shadowRadius = 5
                    colorPickerView.layer.cornerRadius = 5
                    colorPickerView.backgroundColor = UIColor(red: CGFloat(244) / CGFloat(255), green: CGFloat(244) / CGFloat(255), blue: CGFloat(244) / CGFloat(255), alpha: 1)
                    return colorPickerView
                }()

            }else{
                toolbar.options = RichEditorDefaultOption.all
            }
        }
    }
    
    //Color Picker
    lazy var colorDotWidth:CGFloat = {
        return self.frame.height - 10
    }()
    lazy var colorDotPadding:CGFloat = {
        return 5
    }()
    
    lazy var colorPickerView: ColorPickerView = {
        let colorPickerView = ColorPickerView(frame: CGRect(x:  0, y: -self.frame.height, width: self.bounds.width, height: self.frame.height))
        colorPickerView.selectionStyle = .none
        colorPickerView.layer.shadowColor = UIColor.clear.cgColor
        colorPickerView.layer.shadowOffset = CGSize.zero
        colorPickerView.layer.shadowOpacity = 0.7
        colorPickerView.layer.shadowRadius = 5
        colorPickerView.layer.cornerRadius = 5
        colorPickerView.backgroundColor = UIColor(red: CGFloat(244) / CGFloat(255), green: CGFloat(244) / CGFloat(255), blue: CGFloat(244) / CGFloat(255), alpha: 1)
        return colorPickerView
    }()
    
    public lazy var toolbar: RichEditorToolbar = {
        let toolbar = RichEditorToolbar(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: self.frame.height))
        toolbar.options = RichEditorDefaultOption.all
        return toolbar
    }()

    var colorEditMode: ColorEditMode!
    
    //Image Picker
    let imagePicker = UIImagePickerController()
    
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.clipsToBounds = true
        self.imagePicker.delegate = self
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func dismissColorPicker() {
        UIView.animate(withDuration: 0.3) {
            self.toolbar.frame.origin.y -= self.frame.height
            self.colorPickerView.frame.origin.y -= self.frame.height
        }
    }
    
    func showColorPicker() {
        UIView.animate(withDuration: 0.3) {
            self.toolbar.frame.origin.y += self.frame.height
            self.colorPickerView.frame.origin.y += self.frame.height
        }
    }
    
}

extension JJRichTextEditor: RichEditorDelegate {
    
    public func richEditor(_ editor: RichEditorView, contentDidChange content: String) {
        if content.isEmpty {
            htmlTextView?.text = "HTML Preview"
        } else {
            htmlTextView?.text = content
        }
    }
    
}

extension JJRichTextEditor: RichEditorToolbarDelegate {
    
    
    public func richEditorToolbarChangeTextColor(_ toolbar: RichEditorToolbar) {
        colorEditMode = .text
        showColorPicker()
    }
    
    public func richEditorToolbarChangeBackgroundColor(_ toolbar: RichEditorToolbar) {
        colorEditMode = .background
        showColorPicker()
    }
    
    public func richEditorToolbarInsertImage(_ toolbar: RichEditorToolbar) {
        self.parentViewController?.present(imagePicker, animated: true, completion: nil)
    }
    
    public func richEditorToolbarInsertLink(_ toolbar: RichEditorToolbar) {
        // Can only add links to selected text, so make sure there is a range selection first
        if toolbar.editor?.hasRangeSelection == true {
            let alert = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton: false))
            let txt = alert.addTextField("http://")
            alert.addButton("OK") {
                toolbar.editor?.insertLink(txt.text!, title: "URL")
            }
            editorView.endEditing(true)
            alert.showEdit("Add Link", subTitle: "Please enter the link in the following textbox")
        }
    }
}

// MARK: - ColorPickerViewDelegate
extension JJRichTextEditor: ColorPickerViewDelegate {
    
    public func colorPickerView(_ colorPickerView: ColorPickerView, didSelectItemAt indexPath: IndexPath) {
        // A color has been selected
        dismissColorPicker()
        let color = colorPickerView.colors[indexPath.row]
        if(colorEditMode == .text) {
            toolbar.editor?.setTextColor(color)
        }else if(colorEditMode == .background){
            toolbar.editor?.setTextBackgroundColor(color)
        }
    }
    
}


// MARK: - ColorPickerViewDelegateFlowLayout
extension JJRichTextEditor: ColorPickerViewDelegateFlowLayout {
    
    public func colorPickerView(_ colorPickerView: ColorPickerView, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: colorDotWidth, height: colorDotWidth)
    }
    
    public func colorPickerView(_ colorPickerView: ColorPickerView, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return colorDotPadding
    }
    
    public func colorPickerView(_ colorPickerView: ColorPickerView, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return colorDotPadding
    }
    
}


// MARK: - ImagePicker Delegate
extension JJRichTextEditor: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        imagePicker.dismiss(animated: true) {
            var imageData:NSData!
            if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
                imageData = image.jpeg(.lowest)
                print("compressed lowest: \(imageData.count)")
                
                let imageDataMedium = image.jpeg(.medium)
                print("compressed medium: \(imageDataMedium.count)")
                
                let imageDataHighest = image.jpeg(.highest)
                print("compressed highest: \(imageDataHighest.count)")
                
                let imageDataPng = image.png
                print("png: \(imageDataPng.count)")
            }
            else if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
                imageData = image.jpeg(.lowest)
                print(imageData.count)
            } else{
                print("Something went wrong")
            }

            let strBase64:String = imageData.base64EncodedString(options: .lineLength64Characters)
            self.toolbar.editor?.insertImage("data:image/png;base64, " + strBase64, alt: "Gravatar")
            
        }
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        imagePicker.dismiss(animated: true, completion: nil)
    }
}


//helper function
extension JJRichTextEditor {
    public var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}

extension UIImage {
    enum JPEGQuality: CGFloat {
        case lowest  = 0
        case low     = 0.25
        case medium  = 0.5
        case high    = 0.75
        case highest = 1
    }
    
    /// Returns the data for the specified image in PNG format
    /// If the image object’s underlying image data has been purged, calling this function forces that data to be reloaded into memory.
    /// - returns: A data object containing the PNG data, or nil if there was a problem generating the data. This function may return nil if the image has no data or if the underlying CGImageRef contains data in an unsupported bitmap format.
    var png: Data? { return UIImagePNGRepresentation(self) }
    
    /// Returns the data for the specified image in JPEG format.
    /// If the image object’s underlying image data has been purged, calling this function forces that data to be reloaded into memory.
    /// - returns: A data object containing the JPEG data, or nil if there was a problem generating the data. This function may return nil if the image has no data or if the underlying CGImageRef contains data in an unsupported bitmap format.
    func jpeg(_ quality: JPEGQuality) -> Data? {
        return UIImageJPEGRepresentation(self, quality.rawValue)
    }
}
 
