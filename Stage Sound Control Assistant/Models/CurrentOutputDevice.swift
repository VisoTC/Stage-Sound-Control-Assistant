import AVFoundation
import Foundation
#if os(macOS)
import CoreAudio
#else
import UIKit
#endif

enum AudioType {
    case Speaker
    case AirPlay
    case Unknow
}

struct CurrentOutputDeviceInfo{
    let name:String
    let type:AudioType
}

class CurrentOutputDevice: ObservableObject {
    static let shared = CurrentOutputDevice()
    @Published var currentOutputDeviceName = "unknow"
    @Published var currentOutputDeviceType:AudioType = .Unknow
    
    private init() {
        self.sync()
        
#if os(macOS)
        let defaultOutputDeviceID = AudioObjectID(kAudioObjectSystemObject)
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDefaultOutputDevice,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        
        AudioObjectAddPropertyListener(defaultOutputDeviceID, &address, audioDeviceDidChange, nil)
#else
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleRouteChange(_:)),
            name: AVAudioSession.routeChangeNotification,
            object: AVAudioSession.sharedInstance()
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleSecondaryAudioHint(_:)),
            name: AVAudioSession.silenceSecondaryAudioHintNotification,
            object: AVAudioSession.sharedInstance()
        )
#endif
    }
    
#if os(macOS)
    deinit {
        let defaultOutputDeviceID = AudioObjectID(kAudioObjectSystemObject)
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDefaultOutputDevice,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        
        AudioObjectRemovePropertyListener(defaultOutputDeviceID, &address, audioDeviceDidChange, nil)
    }
#else
    deinit {
        NotificationCenter.default.removeObserver(self, name: AVAudioSession.routeChangeNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: AVAudioSession.silenceSecondaryAudioHintNotification, object: nil)
    }
    
    @objc func handleRouteChange(_ notification: Notification) {
        self.sync()
    }
    
    @objc func handleSecondaryAudioHint(_ notification: Notification) {
        self.sync()
    }
#endif
    
    static func getCurrentOutputDevice() -> CurrentOutputDeviceInfo {
#if os(macOS)
        let defaultOutputDeviceID = AudioObjectID(kAudioObjectSystemObject)
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDefaultOutputDevice,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )

        var deviceID: AudioObjectID = 0
        var propertySize = UInt32(MemoryLayout<AudioObjectID>.size)

        let status = AudioObjectGetPropertyData(
            defaultOutputDeviceID,
            &propertyAddress,
            0,
            nil,
            &propertySize,
            &deviceID
        )

        if status == noErr {
            // 获取设备名称
            var deviceName: CFString? = nil
            var propertySize = UInt32(MemoryLayout<CFString?>.size)
            
            var propertyAddressName = AudioObjectPropertyAddress(
                mSelector: kAudioObjectPropertyName,
                mScope: kAudioObjectPropertyScopeGlobal,
                mElement: kAudioObjectPropertyElementMain
            )
            
            let nameStatus = withUnsafeMutablePointer(to: &deviceName) { deviceNamePtr in
                AudioObjectGetPropertyData(deviceID, &propertyAddressName, 0, nil, &propertySize, deviceNamePtr)
            }
            
            // 获取设备传输类型
            var transportType: UInt32 = 0
            propertySize = UInt32(MemoryLayout<UInt32>.size)
            var propertyAddressType = AudioObjectPropertyAddress(
                mSelector: kAudioDevicePropertyTransportType,
                mScope: kAudioObjectPropertyScopeGlobal,
                mElement: kAudioObjectPropertyElementMain
            )
            
            let typeStatus = AudioObjectGetPropertyData(deviceID, &propertyAddressType, 0, nil, &propertySize, &transportType)
            
            // 解析设备类型
            var deviceType: AudioType = .Unknow
            if typeStatus == noErr {
                print(transportType)
                switch transportType {
                case kAudioDeviceTransportTypeBuiltIn:
                    fallthrough
                case kAudioDeviceTransportTypeUSB:
                    fallthrough
                case kAudioDeviceTransportTypeBluetooth:
                    fallthrough
                case kAudioDeviceTransportTypeBluetoothLE:
                    fallthrough
                case kAudioDeviceTransportTypeHDMI:
                    fallthrough
                case kAudioDeviceTransportTypeAVB:
                    fallthrough
                case kAudioDeviceTransportTypePCI:
                    fallthrough
                case kAudioDeviceTransportTypeVirtual:
                    deviceType = .Speaker
                case kAudioDeviceTransportTypeAirPlay:
                    deviceType = .AirPlay // 判断是否为 AirPlay
                default:
                    deviceType = .Unknow
                }
            }
            
            // 返回设备信息
            if nameStatus == noErr, let deviceName = deviceName as String? {
                return CurrentOutputDeviceInfo(name: deviceName, type: deviceType)
            }
        }

        return CurrentOutputDeviceInfo(name: "Unknow", type: .Unknow)
#else
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setActive(true)
            let currentRoute = audioSession.currentRoute
            if let currentOutput = currentRoute.outputs.first {
                var currentOutputType = AudioType.Unknow
                switch (currentOutput.portType.rawValue){
                case "AirPlay":
                    currentOutputType = .AirPlay
                case "Speaker":
                    currentOutputType = .Speaker
                default:
                    currentOutputType = .Unknow
                }
                return CurrentOutputDeviceInfo(name: currentOutput.portName,type:currentOutputType)
            }
            
        } catch {
            print("无法获取当前播放设备：\(error.localizedDescription)")
        }
        return CurrentOutputDeviceInfo(name: "Unknow",type:.Unknow)
#endif
    }
    
    func sync() {
        DispatchQueue.main.async {
            let info = CurrentOutputDevice.getCurrentOutputDevice()
            print("当前播放设备:",info)
            self.currentOutputDeviceName = info.name
            self.currentOutputDeviceType = info.type
        }
    }
}

#if os(macOS)
private let audioDeviceDidChange: AudioObjectPropertyListenerProc = {
    (objectID, numberAddresses, addresses, clientData) in
    CurrentOutputDevice.shared.sync()
    return noErr
}
#endif
