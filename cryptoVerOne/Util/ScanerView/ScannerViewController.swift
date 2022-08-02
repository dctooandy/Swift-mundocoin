//
//  ScannerViewController.swift
//  cryptoVerOne
//
//  Created by AndyChen on 2022/5/13.
//

import Foundation
import AVFoundation
import UIKit
import Toaster
import SnapKit
import RxCocoa
import RxSwift

class ScannerViewController: BaseViewController, AVCaptureMetadataOutputObjectsDelegate, UIImagePickerControllerDelegate {
    // MARK:業務設定
    private let onSacnSuccessAction = PublishSubject<String>()
    private let dpg = DisposeBag()
    var captureSession: AVCaptureSession!
    // MARK: -
    // MARK:UI 設定
    var previewLayer: AVCaptureVideoPreviewLayer!
    var qrCodeFrameView:UIView?
    let openAlbumLabel:UILabel = {
        let label = UILabel()
        label.font = Fonts.PlusJakartaSansBold(20)
        label.textColor = Themes.green13BBB1
        return label
    }()
    var imagePicker = UIImagePickerController()
    // MARK: -
    // MARK:Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        seupUI()
        setupFrame()
        setupLabel()
        setupImagePicker()
        bindLabel()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if (captureSession?.isRunning == false) {
            captureSession.startRunning()
        }
        bindWhenAppear()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }
    }
    
    
    func seupUI()
    {
        view.backgroundColor = UIColor.black
        captureSession = AVCaptureSession()
        // 取得 AVCaptureDevice 類別的實體來初始化一個device物件，並提供video
        // 作為媒體型態參數
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput

        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }

        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            failed()
            return
        }

        let metadataOutput = AVCaptureMetadataOutput()

        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)

            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            failed()
            return
        }

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)

        captureSession.startRunning()
    }
    func setupFrame()
    {
        // 初始化 QR Code Frame 來突顯 QR code
        qrCodeFrameView = UIView()
        qrCodeFrameView?.layer.borderColor = UIColor.green.cgColor
        qrCodeFrameView?.layer.borderWidth = 2
        view.addSubview(qrCodeFrameView!)
        qrCodeFrameView?.snp.makeConstraints({ make in
            make.center.equalToSuperview()
            make.size.equalTo(300)
        })
        view.bringSubviewToFront(qrCodeFrameView!)
    }
    func setupLabel()
    {
        openAlbumLabel.text = "Scan QRCode From Image Album"
        openAlbumLabel.layer.borderColor = Themes.purple6149F6.cgColor
        openAlbumLabel.layer.borderWidth = 1
        view.addSubview(openAlbumLabel)
        openAlbumLabel.snp.makeConstraints({ make in
            make.centerX.equalToSuperview()
            make.top.equalTo(qrCodeFrameView!.snp.bottom).offset(60)
//            make.width.equalTo(60)
//            make.height.equalTo(30)
        })
        view.bringSubviewToFront(openAlbumLabel)
        openAlbumLabel.isHidden = true
    }
    func setupImagePicker()
    {
        imagePicker.modalPresentationStyle = UIModalPresentationStyle.currentContext
        imagePicker.delegate = self
    }
    func bindLabel()
    {
        openAlbumLabel.rx.click.subscribeSuccess { [self] _ in
            if AuthorizeService.share.authorizePhoto()
            {
                Log.v("開始使用相機相簿")
                present(imagePicker, animated: true)
            }
        }.disposed(by: dpg)
    }
    func failed() {
        let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
        captureSession = nil
    }

    func bindWhenAppear()
    {
        AuthorizeService.share.rxShowAlert().subscribeSuccess { alertVC in
            UIApplication.topViewController()?.present(alertVC, animated: true, completion: nil)
        }.disposed(by: dpg)
    }
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()

        // 檢查 metadataObjects 陣列是否為非空值，它至少需包含一個物件
           if metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
            Toast.show(msg: "No QR code is detected")
            return
           }
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            qrCodeFrameView?.frame = readableObject.bounds
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            found(code: stringValue)
        }
        if ((self.presentingViewController?.isKind(of: AddNewAddressViewController.self)) != nil)
        {
            dismiss(animated: true)
        }else
        {
            self.navigationController?.popViewController(animated: true)
        }
//        dismiss(animated: true)
    }

    func found(code: String) {
        print(code)
        onSacnSuccessAction.onNext(code)
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    func rxSacnSuccessAction() -> Observable<String>
    {
        return onSacnSuccessAction.asObserver()
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        if let qrcodeImg = info[UIImagePickerController.InfoKey(rawValue: UIImagePickerController.InfoKey.originalImage.rawValue) ] as? UIImage {
               let detector:CIDetector=CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy:CIDetectorAccuracyHigh])!
               let ciImage:CIImage=CIImage(image:qrcodeImg)!
               var qrCodeLink=""
     
               let features=detector.features(in: ciImage)
               for feature in features as! [CIQRCodeFeature] {
                   qrCodeLink += feature.messageString!
               }
               
               if qrCodeLink=="" {
                   print("nothing")
               }else{
                   print("message: \(qrCodeLink)")
                   onSacnSuccessAction.onNext(qrCodeLink)
                   popVC()
               }
           }
           else{
              print("Something went wrong")
           }
        imagePicker.dismiss(animated: true)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        self.dismiss(animated: true)
    }
}
