//
//  ContentView.swift
//  MacOsSoundTest
//
//  Created by Administrator on 22.11.2021.
//

import SwiftUI
import AVFAudio

var audioPlayer: AVAudioPlayer!


struct ContentView: View {
    let audioEngine: AVAudioEngine = .init()
    let audioPlayerNode: AVAudioPlayerNode = .init()
    @State var audioEngineRunning: Bool = false

    var body: some View {
        VStack {
            Button("No factory registered for id error") {
                // https://stackoverflow.com/questions/50220822/swift-query-to-determine-default-input-device-on-mac-os
                var inputAudioDevice = "" as CFString // AudioDeviceID(0)
                var inputDeviceSize = UInt32(MemoryLayout.size(ofValue: inputAudioDevice))
                var address = AudioObjectPropertyAddress(
                    mSelector: kAudioDevicePropertyDeviceNameCFString, //kAudioHardwarePropertyDefaultInputDevice,
                    mScope: kAudioObjectPropertyScopeGlobal,
                    mElement: kAudioObjectPropertyElementMain
                )
                let status = AudioObjectGetPropertyData(
                    AudioObjectID(kAudioObjectSystemObject),
                    &address,
                    0,
                    nil,
                    &inputDeviceSize,
                    &inputAudioDevice
                )
                print(SecCopyErrorMessageString(status, nil)!)
            }
            Button("NSSound") {
                let url = URL(string: "file:///System/Library/Sounds/Glass.aiff")
                let sound = NSSound(contentsOf: url!, byReference: true)
                // let sound = NSSound(named:"Glass")
                sound?.play()
            }
            Button("AVAudioPlayer") {
                do {
                    let url = URL(string: "file:///System/Library/Sounds/Glass.aiff")
                    try audioPlayer = AVAudioPlayer(contentsOf: url!, fileTypeHint: "aiff")
                    audioPlayer?.prepareToPlay()
                    audioPlayer?.play()
                } catch{
                    print("AVAudioPlayer error: \(error.localizedDescription)")
                }
            }
            Button("AVAudioEngine start") {
                audioEngine.attach(audioPlayerNode)
                audioEngine.connect(audioPlayerNode, to: audioEngine.outputNode, format: nil)
                audioEngine.prepare()
                try! audioEngine.start()
                audioEngineRunning = true
            }
            .disabled(audioEngineRunning)
            Button("AVAudioEngine play") {
                let url = URL(string: "file:///System/Library/Sounds/Glass.aiff")
                let audioFile = try! AVAudioFile(forReading: url!)
                if audioPlayerNode.isPlaying {
                    audioPlayerNode.stop()
                }
                audioPlayerNode.scheduleFile(audioFile, at: nil)
                audioPlayerNode.play()
            }
            .disabled(!audioEngineRunning)
            Button("SystemSoundID") {
                let url = URL(string: "file:///System/Library/Sounds/Glass.aiff")
                var soundID:SystemSoundID = 0
                AudioServicesCreateSystemSoundID(url! as CFURL, &soundID)
                AudioServicesPlaySystemSound(soundID)
            }
        }
        .padding()
        .fixedSize()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
