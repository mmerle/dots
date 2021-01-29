#!/usr/bin/swift

// Required parameters:
// @raycast.schemaVersion 1
// @raycast.title Toggle AirPods
// @raycast.mode silent

// Optional parameters:
// @raycast.packageName Audio
// @raycast.icon images/airpods.png

import IOBluetooth

let deviceAddress = "24-D0-DF-84-76-F8"

func toggleAirPods() {
    guard let bluetoothDevice = IOBluetoothDevice(addressString: deviceAddress) else {
        print("Device not found")
        exit(1)
    }

    if !bluetoothDevice.isPaired() {
        print("Device not paired")
        exit(1)
    }

    if bluetoothDevice.isConnected() {
        print("AirPods Disconnected")
        bluetoothDevice.closeConnection()
    } else {
        print("AirPods Connected")
        bluetoothDevice.openConnection()
    }
}

toggleAirPods()