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

class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    // MARK:業務設定
    private let onSacnSuccessAction = PublishSubject<String>()
    private let dpg = DisposeBag()
    var captureSession: AVCaptureSession!
    // MARK: -
    // MARK:UI 設定
    var previewLayer: AVCaptureVideoPreviewLayer!
    var qrCodeFrameView:UIView?
    
    // MARK: -
    // MARK:Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        seupUI()
        setupFrame()
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
    func failed() {
        let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
        captureSession = nil
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if (captureSession?.isRunning == false) {
            captureSession.startRunning()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }
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
        self.navigationController?.popViewController(animated: true)
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
}
