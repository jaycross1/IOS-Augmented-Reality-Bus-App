//
//  QRCodeScannerViewController.swift
//  ImageDetect


import UIKit
import AVFoundation
import Alamofire
//alamofire works by fetching data from qr code through a http request

// This page scans QRCode
class QRCodeScannerViewController: UIViewController {
    
    @IBOutlet weak var qrFrameImageBox: UIImageView!
    @IBOutlet weak var scanedImageView: UIImageView!
    //this displays the qr code grids
    var captureSession = AVCaptureSession()
    //this is making a private session
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    //this will display the augmented reality 3D models
    var qrCodeFrameView: UIView?
    var scannedImage: UIImage!
    var isTryToUploadQr = true
    //variables
    
    
    private let supportedCodeTypes = [AVMetadataObject.ObjectType.upce,
                                      AVMetadataObject.ObjectType.code39,
                                      AVMetadataObject.ObjectType.code39Mod43,
                                      AVMetadataObject.ObjectType.code93,
                                      AVMetadataObject.ObjectType.code128,
                                      AVMetadataObject.ObjectType.ean8,
                                      AVMetadataObject.ObjectType.ean13,
                                      AVMetadataObject.ObjectType.aztec,
                                      AVMetadataObject.ObjectType.pdf417,
                                      AVMetadataObject.ObjectType.itf14,
                                      AVMetadataObject.ObjectType.dataMatrix,
                                      AVMetadataObject.ObjectType.interleaved2of5,
                                      AVMetadataObject.ObjectType.qr]
    //This is different types of qr codes, similiar to pdf, qr codes etc

    override func viewDidLoad() {
        super.viewDidLoad()

        // start QR Code Scanner
         self.setupQRCodeScanner()
        //self points to this controller class, and its telling you to set up the grids
    }
    
    override func viewWillDisappear(_ animated: Bool) {

    }
    
    override func viewWillAppear(_ animated: Bool) {
        //this function will set up this contorller in such a way that when the grid pops up and you scan the qr code, so it will make this controller ready to upload the image to the server

        // able to upload scanned image to server
        self.isTryToUploadQr = true
        
        
        
        // Show Qr Scan Box On Screen
        DispatchQueue.main.async {
            // brings Qr Frame on top
            self.view.bringSubviewToFront(self.qrFrameImageBox)
            // brings Selected Qr Image View on top also
            self.view.bringSubviewToFront(self.scanedImageView)
            
            // set images of Qr Frame & initially Set Selected image to empty
            self.qrFrameImageBox.image = UIImage(named: "scan.png")
            self.scanedImageView.image = nil
        }
    }
    
    
    //Initalize camera and scanning
    func setupQRCodeScanner() {
        // Get the back-facing camera for capturing videos
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .back)
        
        guard let captureDevice = deviceDiscoverySession.devices.first else {
            //it will show the error to show the back camera is not on etc
            print("Failed to get the camera device")
            return
        }
        
        do {
            //capture all the qr code
            // Get an instance of the AVCaptureDeviceInput class using the previous device object.
            let input = try AVCaptureDeviceInput(device: captureDevice)
            //fetches everything the camera sees
            
            
            captureSession.addInput(input)
            // Set the input device on the capture session.
            
            // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
            let captureMetadataOutput = AVCaptureMetadataOutput()
            //gets meta data like png, type size etc
            captureSession.addOutput(captureMetadataOutput)
            
            // Set delegate and use the default dispatch queue to execute the call back
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = supportedCodeTypes
            //this makes a que to save what you are currently capturing from the screen
            
            //            captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
            
        } catch {
            // If any error occurs, simply print it out and don't continue any more.
            print(error)
            return
        }
        
        // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        //capturing video preview layer
        videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        //re size the video to the whole screen according to the phone size
        videoPreviewLayer?.frame = view.layer.bounds
        view.layer.addSublayer(videoPreviewLayer!)
        
        // Start video capture. camera open to specific session etc
        captureSession.startRunning()
        
        // Initialize QR Code Frame to highlight the QR code
        qrCodeFrameView = UIView()
        
        if let qrCodeFrameView = qrCodeFrameView {
            qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
            qrCodeFrameView.layer.borderWidth = 2
            view.addSubview(qrCodeFrameView)
            view.bringSubviewToFront(qrCodeFrameView)
        } //if camera detects qr code within the grid the grid goes green
    }
    
    
    // Uploading image to node server
    func uploadImage(callback: @escaping ((_ success: Bool,_ list:[QRCodeData]) -> Void)) {
        let image = self.scannedImage//UIImage(named: "img1")
        let imgData =  image!.jpegData(compressionQuality: 0.1)!
        //compressed to upload image very quickly
        //converts image you see on the screen into jpeg
        //alamofire uploads scanned image to node server
        Alamofire.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(imgData, withName: "upload",fileName: "\(Date().timeIntervalSince1970).png", mimeType: "image/png")
        },to:"http://qrapp.apic.eu-gb.mybluemix.net/upload")
        { (result) in
            switch result {
            case .success(let upload, _,_ ):
                
                // this is a uploading progress
                upload.uploadProgress(closure: { (progress) in
                    print("Upload Progress: \(progress.fractionCompleted)")
                })
                
              
                // this is a server response
                //print(upload.response))
                upload.responseJSON { response in
                    print("response: \(response)")
                    // check server respond a valid type of data or not
                    if let array = response.result.value as? [[String: Any]] {
                        //this list contain data that you got from the server
                        if let list = QRCodeData.getList(array: array) {
                            // Success case, return list of Buses
                            callback(true, list)
                            return
                        }
                    }
                    // Failure case, return empty list of Buses
                    callback(false, [])
                }
                
            // it is failure condition
            case .failure(let encodingError):
                print(encodingError)
                // Failure case, return empty list of Buses
                callback(false, [])
            }
        }
    }
    



}


extension QRCodeScannerViewController: AVCaptureMetadataOutputObjectsDelegate {
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // Check if the metadataObjects array is not nil and it contains at least one object.
        //checks to see if any bus data is in the metdata
        if metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
            return
        }// if there is no metadata then the screen does not produce any 3D models
        
        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        //making a variable and then setting metadata into this variable
        // If the found metadata is equal to the QR code metadata (or barcode) then update the status label's text and set the bounds
        if supportedCodeTypes.contains(metadataObj.type) {
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            qrCodeFrameView?.frame = barCodeObject!.bounds
            
            if metadataObj.stringValue != nil {
                //if its not equal to nil it will run
                //this is when you very first start to scan qr code to check for the data which will show an alert
                        if let image = self.getQRCodeImage(value: metadataObj.stringValue!) {
                            self.scannedImage = image
                            self.scanedImageView.image = image
                            //it gets data from qr code once it is scanned
                            if self.isTryToUploadQr{
                                self.isTryToUploadQr = false
                                CodeUtilities.sharedInstance.disableScreen(view: self.view)
                                self.uploadImage(callback: {(success: Bool,list:[QRCodeData])  in
                                    CodeUtilities.sharedInstance.enableScreeen()
                                    if success {
                                        self.isTryToUploadQr = false
                                        // Do success code
                               //         DispatchQueue.main.async {
                                       //     self.captureSession.stopRunning()
                                        
                                        //you have one session per qr code scanning. it stops any session previously running for when you start your session.
                                            if list.count != 0{
                                                //checks if there is still something in the 3D model in the list
                                                let vc = self.storyboard?.instantiateViewController(withIdentifier: "ViewController") as! AugmentedController
                                                vc.bussesData = list
                                               self.present(vc, animated: true, completion: nil)
                                                
                                            }else{
                                                //This is the second qr code
                                                // show alert to user that no data found related to this QR Code
                                                self.scanedImageView.image = nil
                                                let alert = UIAlertController(title: "Alert", message: "No Buses records here related to this QR Code.", preferredStyle: .alert)
                                                let okAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                                                alert.addAction(okAction)
                                                self.present(alert, animated: true, completion: nil)
                                            }//when the session is already running then this alert will run as a loop
                                           
                                      //  }
                                    }
                                    else {
                                        
                                        // show alert to user that error comes 

                                        self.isTryToUploadQr = true
                                        self.scanedImageView.image = nil
                                        let alert = UIAlertController(title: "Error", message: "Something went wrong.", preferredStyle: .alert)
                                        let okAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                                        alert.addAction(okAction)
                                        self.present(alert, animated: true, completion: nil)
                                    }
                                })
                            }
                           
                        }
                    
                   
                
            }
        }
    }
    
    // Generating QRCode from string
    func getQRCodeImage(value: String) -> UIImage? {
        let data = value.data(using: String.Encoding.ascii)
        guard let qrFilter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
        qrFilter.setValue(data, forKey: "inputMessage")
        guard let qrImage = qrFilter.outputImage else { return nil }
        let transform = CGAffineTransform(scaleX: 10, y: 10)
        let scaledQrImage = qrImage.transformed(by: transform)
        let context = CIContext(options: nil)
        let cgImage = context.createCGImage(scaledQrImage, from: scaledQrImage.extent)
        return UIImage(cgImage: cgImage!)
    }
}
